// ignore_for_file: unused_result

import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/commas.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../Provider/customer_provider.dart';
import '../../Provider/daily_transaction_provider.dart';
import '../../Provider/due_transaction_provider.dart';
import '../../Provider/product_provider.dart';
import '../../Provider/profile_provider.dart';
import '../../Provider/sales_returns_provider.dart';
import '../../Provider/transactions_provider.dart';
import '../../const.dart';
import '../../currency.dart';
import '../../model/add_to_cart_model.dart';
import '../../model/daily_transaction_model.dart';
import '../../model/sale_transaction_model.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';

class SalesReturnScreen extends StatefulWidget {
  const SalesReturnScreen({super.key, required this.saleTransactionModel});

  final SaleTransactionModel saleTransactionModel;

  static const String route = '/sales_Return';

  @override
  State<SalesReturnScreen> createState() => _SalesReturnScreenState();
}

class _SalesReturnScreenState extends State<SalesReturnScreen> {
  double calculateAmountFromPercentage(double percentage, double price) {
    return (percentage * price) / 100;
  }

  num getTotalReturnAmount() {
    num returnAmount = 0;
    for (var element in returnList) {
      if (element.quantity > 0) {
        returnAmount += element.quantity * (num.tryParse(element.subTotal.toString()) ?? 0);
      }
    }
    return returnAmount;
  }

  Future<void> saleReturn({required SaleTransactionModel salesModel, required SaleTransactionModel orginal, required WidgetRef consumerRef, required BuildContext context}) async {
    try {
      EasyLoading.show(status: 'Processando...', dismissOnTap: false);

      ///_________Push_on_Sale_return_dataBase____________________________________________________________________________
      DatabaseReference ref = FirebaseDatabase.instance.ref("${await getUserID()}/Sales Return");
      await ref.push().set(salesModel.toJson());

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

        //________Update_Serial_Number____________________________________________________

        if (element.serialNumber != null && element.serialNumber!.isNotEmpty) {
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
        paymentOut: ((orginal.totalAmount ?? 0) - (orginal.dueAmount ?? 0)) > (salesModel.totalAmount ?? 0)
            ? (salesModel.totalAmount ?? 0)
            : ((orginal.totalAmount ?? 0) - (orginal.dueAmount ?? 0)),
        remainingBalance: ((orginal.totalAmount ?? 0) - (orginal.dueAmount ?? 0)) > (salesModel.totalAmount ?? 0)
            ? (salesModel.totalAmount ?? 0)
            : ((orginal.totalAmount ?? 0) - (orginal.dueAmount ?? 0)),
        id: salesModel.invoiceNumber,
        saleTransactionModel: salesModel,
      );

      postDailyTransaction(dailyTransactionModel: dailyTransaction);

      ///_________DueUpdate___________________________________________________________________________________
      if (salesModel.customerName != 'Guest' && (orginal.dueAmount ?? 0) > 0) {
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

        num dueNow = (orginal.dueAmount ?? 0) - (salesModel.totalAmount ?? 0);

        int totalDue = dueNow.isNegative ? 0 : previousDue - salesModel.totalAmount!.toInt();
        dueUpdateRef.child(key!).update({'due': '$totalDue'});
      }

      consumerRef.refresh(allCustomerProvider);
      consumerRef.refresh(saleReturnProvider);
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

  DateTime selectedDueDate = DateTime.now();

  Future<void> _selectedDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: selectedDueDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDueDate) {
      setState(() {
        selectedDueDate = picked;
      });
    }
  }

  List<AddToCartModel> returnList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkCurrentUserAndRestartApp();

    for (var element in widget.saleTransactionModel.productList!) {
      AddToCartModel p = AddToCartModel(
        warehouseName: element.warehouseName,
        warehouseId: element.warehouseId,
        productPurchasePrice: element.productPurchasePrice,
        productImage: element.productImage,
        itemCartIndex: element.itemCartIndex,
        productBrandName: element.productBrandName,
        productDetails: element.productDetails,
        productId: element.productId,
        productName: element.productName,
        productWarranty: element.productWarranty,
        quantity: 0,
        serialNumber: element.serialNumber,
        stock: element.quantity,
        subTotal: element.subTotal,
        uniqueCheck: element.uniqueCheck,
        unitPrice: element.unitPrice,
        uuid: element.uuid,
        subTaxes: element.subTaxes,
        excTax: element.excTax,
        groupTaxName: element.groupTaxName,
        groupTaxRate: element.groupTaxRate,
        incTax: element.incTax,
        margin: element.margin,
        taxType: element.taxType,
      );
      returnList.add(p);
    }
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
                                  Text(
                                    lang.S.of(context).saleReturn,
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Divider(
                                    thickness: 1.0,
                                    color: kGreyTextColor.withOpacity(0.2),
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ///___________Customer_______________________________
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(left: 5),
                                                  child: Text('Nome do Cliente'),
                                                ),
                                                SizedBox(
                                                  height: 40.0,
                                                  child: Card(
                                                    color: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                      side: const BorderSide(color: kLitGreyColor),
                                                    ),
                                                    child: Center(
                                                        child: Text(
                                                      widget.saleTransactionModel.customerName,
                                                      style: const TextStyle(color: kTitleColor, fontWeight: FontWeight.bold),
                                                    )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          ///___________Invoice_______________________________
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(left: 5),
                                                  child: Text('Fatura'),
                                                ),
                                                SizedBox(
                                                  height: 40.0,
                                                  child: Card(
                                                    color: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                      side: const BorderSide(color: kLitGreyColor),
                                                    ),
                                                    child: Center(
                                                        child: Text(
                                                      "#${widget.saleTransactionModel.invoiceNumber}",
                                                      style: const TextStyle(color: kTitleColor, fontWeight: FontWeight.bold),
                                                    )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          ///__________Date_______________________________
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(left: 5),
                                                  child: Text('Data'),
                                                ),
                                                SizedBox(
                                                  height: 40.0,
                                                  child: Card(
                                                    color: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                      side: const BorderSide(color: kLitGreyColor),
                                                    ),
                                                    child: Container(
                                                      decoration: const BoxDecoration(),
                                                      child: Center(
                                                        child: Text(
                                                          '${selectedDueDate.day}/${selectedDueDate.month}/${selectedDueDate.year}',
                                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                    ).onTap(() => _selectedDueDate(context)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 20),

                                      ///___________Cart_List_Show _and buttons__________________________________
                                      IntrinsicWidth(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: kWhite,
                                            border: Border.all(width: 1, color: kGreyTextColor.withOpacity(0.3)),
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(15),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: context.width(),
                                                height: 350,
                                                // height: context.height() < 720 ? 720 - 410 : context.height(),
                                                decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: kGreyTextColor.withOpacity(0.3)))),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(15),
                                                        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: kGreyTextColor.withOpacity(0.3)))),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            SizedBox(width: 250, child: Text(lang.S.of(context).productNam)),
                                                            const SizedBox(width: 110, child: Text('Qtd da Venda')),
                                                            const SizedBox(width: 110, child: Text('Qtd a Devolver')),
                                                            SizedBox(width: 70, child: Text(lang.S.of(context).price)),
                                                            SizedBox(width: 100, child: Text(lang.S.of(context).subTotal)),
                                                          ],
                                                        ),
                                                      ),
                                                      ListView.builder(
                                                        shrinkWrap: true,
                                                        physics: const NeverScrollableScrollPhysics(),
                                                        itemCount: returnList.length,
                                                        itemBuilder: (BuildContext context, int index) {
                                                          TextEditingController quantityController = TextEditingController(text: returnList[index].quantity.toString());
                                                          return Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  ///______________name__________________________________________________
                                                                  Container(
                                                                    width: 250,
                                                                    padding: const EdgeInsets.only(left: 15),
                                                                    child: Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        Flexible(
                                                                          child: Text(
                                                                            returnList[index].productName ?? '',
                                                                            maxLines: 2,
                                                                            overflow: TextOverflow.ellipsis,
                                                                            style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                        // Row(
                                                                        //   children: [
                                                                        //     Flexible(
                                                                        //       child: Text(
                                                                        //         cartList[index].serialNumber!.isEmpty ? '' : 'IMEI/Serial: ${cartList[index].serialNumber}',
                                                                        //         maxLines: 1,
                                                                        //         style: kTextStyle.copyWith(fontSize: 12, color: kTitleColor),
                                                                        //       ),
                                                                        //     ),
                                                                        //   ],
                                                                        // )
                                                                      ],
                                                                    ),
                                                                  ),

                                                                  ///____________quantity_________________________________________________
                                                                  SizedBox(
                                                                    width: 110,
                                                                    child: Center(
                                                                      child: Container(
                                                                          width: 60,
                                                                          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 2.0, bottom: 2.0),
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(2.0),
                                                                            color: Colors.white,
                                                                          ),
                                                                          child: Text(returnList[index].stock.toString())),
                                                                    ),
                                                                  ),

                                                                  ///____________return_quantity_________________________________________________
                                                                  SizedBox(
                                                                    width: 110,
                                                                    child: Center(
                                                                      child: Row(
                                                                        children: [
                                                                          const Icon(FontAwesomeIcons.solidSquareMinus, color: kBlueTextColor).onTap(() {
                                                                            setState(() {
                                                                              returnList[index].quantity > 0 ? returnList[index].quantity-- : returnList[index].quantity = 0;
                                                                            });
                                                                          }),
                                                                          Container(
                                                                            width: 60,
                                                                            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 2.0, bottom: 2.0),
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(2.0),
                                                                              color: Colors.white,
                                                                            ),
                                                                            child: TextFormField(
                                                                              controller: quantityController,
                                                                              textAlign: TextAlign.center,
                                                                              onChanged: (value) {
                                                                                if (returnList[index].stock!.toInt() < value.toInt()) {
                                                                                  EasyLoading.showError('Fora de estoque');
                                                                                  quantityController.clear();
                                                                                } else if (value == '') {
                                                                                  returnList[index].quantity = 1;
                                                                                } else if (value == '0') {
                                                                                  returnList[index].quantity = 1;
                                                                                } else {
                                                                                  returnList[index].quantity = value.toInt();
                                                                                }
                                                                              },
                                                                              onFieldSubmitted: (value) {
                                                                                if (value == '') {
                                                                                  setState(() {
                                                                                    returnList[index].quantity = 1;
                                                                                  });
                                                                                } else {
                                                                                  setState(() {
                                                                                    returnList[index].quantity = value.toInt();
                                                                                  });
                                                                                }
                                                                              },
                                                                              decoration: const InputDecoration(border: InputBorder.none),
                                                                            ),
                                                                          ),
                                                                          const Icon(FontAwesomeIcons.solidSquarePlus, color: kBlueTextColor).onTap(() {
                                                                            if (returnList[index].quantity < returnList[index].stock!.toInt()) {
                                                                              setState(() {
                                                                                returnList[index].quantity += 1;
                                                                                toast(returnList[index].quantity.toString());
                                                                              });
                                                                            } else {
                                                                              EasyLoading.showError('Fora de estoque');
                                                                            }
                                                                          }),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),

                                                                  ///______price___________________________________________________________
                                                                  SizedBox(
                                                                    width: 70,
                                                                    child: TextFormField(
                                                                      initialValue: myFormat.format(double.tryParse(returnList[index].subTotal) ?? 0),
                                                                      onChanged: (value) {
                                                                        if (value == '') {
                                                                          setState(() {
                                                                            returnList[index].subTotal = 0.toString();
                                                                          });
                                                                        } else if (double.tryParse(value) == null) {
                                                                          EasyLoading.showError('Enter a valid Price');
                                                                        } else {
                                                                          setState(() {
                                                                            returnList[index].subTotal = double.parse(value).toStringAsFixed(2);
                                                                          });
                                                                        }
                                                                      },
                                                                      onFieldSubmitted: (value) {
                                                                        if (value == '') {
                                                                          setState(() {
                                                                            returnList[index].subTotal = 0.toString();
                                                                          });
                                                                        } else if (double.tryParse(value) == null) {
                                                                          EasyLoading.showError('Enter a valid Price');
                                                                        } else {
                                                                          setState(() {
                                                                            returnList[index].subTotal = double.parse(value).toStringAsFixed(2);
                                                                          });
                                                                        }
                                                                      },
                                                                      decoration: const InputDecoration(border: InputBorder.none),
                                                                    ),
                                                                  ),

                                                                  ///___________subtotal____________________________________________________
                                                                  SizedBox(
                                                                    width: 100,
                                                                    child: Text(
                                                                      myFormat.format(double.tryParse((double.parse(returnList[index].subTotal) *
                                                                                  ((returnList[index].stock ?? 0) - returnList[index].quantity))
                                                                              .toStringAsFixed(2)) ??
                                                                          0),
                                                                      style: kTextStyle.copyWith(color: kTitleColor),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Container(
                                                                width: double.infinity,
                                                                height: 1,
                                                                color: kGreyTextColor.withOpacity(0.3),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      ///_______price_section_____________________________________________
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          children: [
                                            ///__________total__________________________________________
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Produtos Totais: ${returnList.length}',
                                                  style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                                ),
                                                const Spacer(),
                                                SizedBox(
                                                  width: context.width() < 1080 ? 1080 * .12 : MediaQuery.of(context).size.width * .12,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(right: 20),
                                                    child: Text(
                                                      'Valor total da devolução',
                                                      textAlign: TextAlign.end,
                                                      style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 204,
                                                  child: Container(
                                                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 4.0, bottom: 4.0),
                                                    decoration: const BoxDecoration(color: kGreenTextColor, borderRadius: BorderRadius.all(Radius.circular(8))),
                                                    child: Center(
                                                      child: Text(
                                                        '${myFormat.format(getTotalReturnAmount())} $currency',
                                                        style: kTextStyle.copyWith(color: kWhite, fontSize: 18.0, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10.0),

                                            ///____________buttons____________________________________________________
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ///________________cancel_button_____________________________________
                                                Expanded(
                                                  flex: 1,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.all(10.0),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.rectangle,
                                                        borderRadius: BorderRadius.circular(10.0),
                                                        color: kRedTextColor,
                                                      ),
                                                      child: Text(
                                                        lang.S.of(context).cancel,
                                                        textAlign: TextAlign.center,
                                                        style: kTextStyle.copyWith(color: kWhite, fontSize: 18.0, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10.0),
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10.0),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.rectangle,
                                                      borderRadius: BorderRadius.circular(2.0),
                                                      color: Colors.yellow,
                                                    ),
                                                    child: Text(
                                                      lang.S.of(context).hold,
                                                      textAlign: TextAlign.center,
                                                      style: kTextStyle.copyWith(color: kWhite, fontSize: 18.0, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ).visible(false),

                                                ///________________payments_________________________________________
                                                const SizedBox(width: 10.0),
                                                Expanded(
                                                  flex: 1,
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      if (!returnList.any((element) => element.quantity > 0)) {
                                                        EasyLoading.showError('Selecione um produto para devolução');
                                                      } else {
                                                        returnList.removeWhere((element) => (element.quantity) <= 0);
                                                        SaleTransactionModel editedTransitionModel = widget.saleTransactionModel;
                                                        (num.tryParse(getTotalReturnAmount().toString()) ?? 0) > (widget.saleTransactionModel.dueAmount ?? 0)
                                                            ? editedTransitionModel.isPaid = true
                                                            : editedTransitionModel.isPaid = false;
                                                        if ((widget.saleTransactionModel.dueAmount ?? 0) > 0) {
                                                          (num.tryParse(getTotalReturnAmount().toString()) ?? 0) >= (widget.saleTransactionModel.dueAmount ?? 0)
                                                              ? editedTransitionModel.dueAmount = 0
                                                              : editedTransitionModel.dueAmount =
                                                                  (widget.saleTransactionModel.dueAmount ?? 0) - (num.tryParse(getTotalReturnAmount().toString()) ?? 0);
                                                        }
                                                        List<AddToCartModel> newProductList = [];
                                                        List<AddToCartModel> oldProduct = widget.saleTransactionModel.productList!;

                                                        for (var p in widget.saleTransactionModel.productList!) {
                                                          if (returnList.any((element) => element.productId == p.productId)) {
                                                            int index = returnList.indexWhere((element) => element.productId == p.productId);
                                                            p.quantity = p.quantity - returnList[index].quantity;
                                                          }

                                                          if (p.quantity > 0) newProductList.add(p);
                                                        }

                                                        editedTransitionModel.productList = newProductList;
                                                        editedTransitionModel.totalAmount =
                                                            (editedTransitionModel.totalAmount ?? 0) - (double.tryParse(getTotalReturnAmount().toString()) ?? 0);

                                                        // myTransitionModel.totalAmount = widget.newTransitionModel.totalAmount!.toDouble();
                                                        ///________________updateInvoice___________________________________________________________OK
                                                        String? key;
                                                        final userId = await getUserID();
                                                        await FirebaseDatabase.instance.ref(userId).child('Sales Transition').orderByKey().get().then((value) {
                                                          for (var element in value.children) {
                                                            final t = SaleTransactionModel.fromJson(jsonDecode(jsonEncode(element.value)));
                                                            if (editedTransitionModel.invoiceNumber == t.invoiceNumber) {
                                                              key = element.key;
                                                            }
                                                          }
                                                        });

                                                        if (newProductList.isEmpty) {
                                                          await FirebaseDatabase.instance.ref(userId).child('Sales Transition').child(key!).remove();
                                                        } else {
                                                          num totalQuantity = 0;
                                                          double lossProfit = 0;
                                                          double totalPurchasePrice = 0;
                                                          double totalSalePrice = 0;
                                                          for (var element in newProductList) {
                                                            if (element.taxType == 'Exclusive') {
                                                              double tax = calculateAmountFromPercentage(
                                                                  element.groupTaxRate.toDouble(), double.tryParse(element.productPurchasePrice.toString()) ?? 0);
                                                              totalPurchasePrice =
                                                                  totalPurchasePrice + ((double.parse(element.productPurchasePrice.toString()) + tax) * element.quantity);
                                                            } else {
                                                              totalPurchasePrice = totalPurchasePrice + (double.parse(element.productPurchasePrice.toString()) * element.quantity);
                                                            }

                                                            totalSalePrice = totalSalePrice + (double.parse(element.subTotal.toString()) * element.quantity);

                                                            totalQuantity = totalQuantity + element.quantity;
                                                          }
                                                          lossProfit =
                                                              ((totalSalePrice - totalPurchasePrice.toDouble()) - double.parse(editedTransitionModel.discountAmount.toString()));
                                                          editedTransitionModel.totalQuantity = totalQuantity;
                                                          editedTransitionModel.lossProfit = lossProfit;

                                                          ///__________total LossProfit & quantity________________________________________________________________
                                                          // final postEditedTransitionModel = ShowEditPaymentPopUp.checkLossProfit(transitionModel: editedTransitionModel);
                                                          await FirebaseDatabase.instance.ref(userId).child('Sales Transition').child(key!).update(editedTransitionModel.toJson());
                                                        }
                                                        SaleTransactionModel invoice = SaleTransactionModel(
                                                          customerName: widget.saleTransactionModel.customerName,
                                                          customerType: widget.saleTransactionModel.customerType,
                                                          customerGst: widget.saleTransactionModel.customerGst,
                                                          customerPhone: widget.saleTransactionModel.customerPhone,
                                                          invoiceNumber: widget.saleTransactionModel.invoiceNumber,
                                                          purchaseDate: widget.saleTransactionModel.purchaseDate,
                                                          customerAddress: widget.saleTransactionModel.customerAddress,
                                                          customerImage: widget.saleTransactionModel.customerImage,
                                                          productList: returnList,
                                                          totalAmount: double.tryParse(getTotalReturnAmount().toString()),
                                                          discountAmount: 0,
                                                          dueAmount: 0,
                                                          isPaid: false,
                                                          lossProfit: 0,
                                                          paymentType: 'Cash',
                                                          returnAmount: 0,
                                                          serviceCharge: 0,
                                                          vat: 0,
                                                          totalQuantity: 0,
                                                        );

                                                        await saleReturn(salesModel: invoice, orginal: widget.saleTransactionModel, consumerRef: ref, context: context);
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.all(10.0),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.rectangle,
                                                        borderRadius: BorderRadius.circular(10.0),
                                                        color: kBlueTextColor,
                                                      ),
                                                      child: Text(
                                                        'Fazer Devolução',
                                                        textAlign: TextAlign.center,
                                                        style: kTextStyle.copyWith(color: kWhite, fontSize: 18.0, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
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
            }),
          ),
        ),
      ),
    );
  }
}
