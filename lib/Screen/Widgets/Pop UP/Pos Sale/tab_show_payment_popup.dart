// ignore_for_file: unused_result, use_build_context_synchronously

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Provider/product_provider.dart';
import 'package:salespro_admin/Provider/transactions_provider.dart';
import 'package:salespro_admin/model/sale_transaction_model.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../../../Provider/customer_provider.dart';
import '../../../../Provider/due_transaction_provider.dart';
import '../../../../Provider/profile_provider.dart';
import '../../../../const.dart';
import '../../../../currency.dart';
import '../../../../model/add_to_cart_model.dart';
import '../../Constant Data/constant.dart';

class TabShowPaymentPopUp extends StatefulWidget {
  const TabShowPaymentPopUp({Key? key, required this.transitionModel}) : super(key: key);
  final SaleTransactionModel transitionModel;

  @override
  State<TabShowPaymentPopUp> createState() => _TabShowPaymentPopUpState();
}

class _TabShowPaymentPopUpState extends State<TabShowPaymentPopUp> {
  List<AddToCartModel> cartList = [];

  String getTotalAmount() {
    double total = 0.0;
    for (var item in widget.transitionModel.productList!) {
      total = total + (double.parse(item.unitPrice) * item.quantity);
    }
    return total.toString();
  }

  List<String> paymentItem = ['Cash', 'Bank', 'Mobile Pay'];
  String selectedPaymentOption = 'Cash';

  DropdownButton<String> getOption() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String des in paymentItem) {
      var item = DropdownMenuItem(
        value: des,
        child: Text(des),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      items: dropDownItems,
      value: selectedPaymentOption,
      onChanged: (value) {
        setState(() {
          selectedPaymentOption = value!;
        });
      },
    );
  }

  double dueAmount = 0.0;
  double returnAmount = 0.0;

  TextEditingController payingAmountController = TextEditingController();
  TextEditingController changeAmountController = TextEditingController();
  TextEditingController dueAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, consumerRef, __) {
        final personalData = consumerRef.watch(profileDetailsProvider);
        return personalData.when(data: (data) {
          return SizedBox(
            width: 1200,
            height: context.height() / 1.3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        lang.S.of(context).createPayment,
                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                      const Spacer(),
                      const Icon(FeatherIcons.x, color: kTitleColor, size: 25.0).onTap(() => {finish(context)})
                    ],
                  ),
                ),
                const Divider(thickness: 1.0, color: kLitGreyColor),
                const SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: kWhite, border: Border.all(color: kLitGreyColor)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    lang.S.of(context).payingAmount,
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 400,
                                  child: AppTextField(
                                    controller: payingAmountController,
                                    onChanged: (value) {
                                      setState(() {
                                        double paidAmount = double.parse(value);
                                        if (paidAmount > getTotalAmount().toDouble()) {
                                          changeAmountController.text = (paidAmount - getTotalAmount().toDouble()).toString();
                                          dueAmountController.text = '0';
                                        } else {
                                          dueAmountController.text = (getTotalAmount().toDouble() - paidAmount).abs().toString();
                                          changeAmountController.text = '0';
                                        }
                                      });
                                    },
                                    showCursor: true,
                                    cursorColor: kTitleColor,
                                    textFieldType: TextFieldType.NAME,
                                    decoration: kInputDecoration.copyWith(
                                      hintText: lang.S.of(context).enterAmount,
                                      hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    lang.S.of(context).changeAmount,
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 400,
                                  child: AppTextField(
                                    controller: changeAmountController,
                                    showCursor: true,
                                    cursorColor: kTitleColor,
                                    textFieldType: TextFieldType.NAME,
                                    decoration: kInputDecoration.copyWith(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    lang.S.of(context).dueAmount,
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 400,
                                  child: AppTextField(
                                    controller: dueAmountController,
                                    showCursor: true,
                                    cursorColor: kTitleColor,
                                    textFieldType: TextFieldType.NAME,
                                    decoration: kInputDecoration.copyWith(
                                      hintText: lang.S.of(context).dueAmountWillShowHere,
                                      hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    lang.S.of(context).paymentType,
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 400,
                                  child: FormField(
                                    builder: (FormFieldState<dynamic> field) {
                                      return InputDecorator(
                                        decoration: const InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                              borderSide: BorderSide(color: kBorderColorTextField, width: 2),
                                            ),
                                            contentPadding: EdgeInsets.only(left: 12.0, right: 10.0, top: 7.0, bottom: 7.0),
                                            floatingLabelBehavior: FloatingLabelBehavior.never),
                                        child: DropdownButtonHideUnderline(child: getOption()),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            SizedBox(
                              width: 700,
                              child: TextFormField(
                                minLines: 1,
                                maxLines: 5,
                                keyboardType: TextInputType.multiline,
                                cursorColor: kTitleColor,
                                decoration: const InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(color: kBorderColorTextField, width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(color: kBorderColorTextField, width: 2),
                                  ),
                                  contentPadding: EdgeInsets.all(7.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: kWhite,
                          border: Border.all(color: kLitGreyColor),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(topLeft: radiusCircular(5.0), topRight: radiusCircular(5.0)),
                                color: kWhite,
                                border: Border.all(color: kLitGreyColor),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    lang.S.of(context).totalProduct,
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${widget.transitionModel.productList?.length}',
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: kWhite,
                                border: Border.all(color: kLitGreyColor),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    lang.S.of(context).vatOrgst,
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '0.00',
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: kWhite,
                                border: Border.all(color: kLitGreyColor),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    lang.S.of(context).shpingOrServices,
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '0.00',
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(bottomLeft: radiusCircular(5.0), bottomRight: radiusCircular(5.0)),
                                color: kLitGreyColor,
                                border: Border.all(color: kLitGreyColor),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    lang.S.of(context).grandTotal,
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '$currency ${getTotalAmount()}',
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20.0),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                              padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0, bottom: 10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: kRedTextColor,
                              ),
                              child: Text(
                                lang.S.of(context).cancel,
                                style: kTextStyle.copyWith(color: kWhite),
                              )).onTap(() => {finish(context)}),
                          const SizedBox(width: 40.0),
                          Container(
                            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0, bottom: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: kBlueTextColor,
                            ),
                            child: Text(
                              lang.S.of(context).submit,
                              style: kTextStyle.copyWith(color: kWhite),
                            ),
                          ).onTap(
                            () async {
                              if (widget.transitionModel.customerType == "Guest" && dueAmountController.text.toDouble() > 0) {
                                EasyLoading.showError('Due is not available For Guest');
                              } else {
                                try {
                                  EasyLoading.show(status: 'Loading...', dismissOnTap: false);

                                  final userId = await getUserID();
                                  DatabaseReference ref = FirebaseDatabase.instance.ref("$userId/Sales Transition");

                                  dueAmountController.text.toDouble() <= 0 ? widget.transitionModel.isPaid = true : widget.transitionModel.isPaid = false;
                                  dueAmountController.text.toDouble() <= 0
                                      ? widget.transitionModel.dueAmount = 0
                                      : widget.transitionModel.dueAmount = dueAmountController.text.toDouble();
                                  changeAmountController.text.toDouble() > 0
                                      ? widget.transitionModel.returnAmount = dueAmountController.text.toDouble().abs()
                                      : widget.transitionModel.returnAmount = 0;
                                  widget.transitionModel.discountAmount = 0.0;
                                  widget.transitionModel.totalAmount = getTotalAmount().toDouble();
                                  widget.transitionModel.paymentType = selectedPaymentOption;

                                  await ref.push().set(widget.transitionModel.toJson());

                                  ///__________StockMange_________________________________________________-

                                  for (var element in widget.transitionModel.productList!) {
                                    decreaseStock(element.productId, element.quantity);
                                  }

                                  ///_________Invoice Increase______________________________________________________
                                  updateInvoice(typeOfInvoice: 'saleInvoiceCounter', invoice: widget.transitionModel.invoiceNumber.toInt());

                                  ///_________DueUpdate______________________________________________________
                                  getSpecificCustomers(phoneNumber: widget.transitionModel.customerPhone, due: dueAmount.toInt());

                                  ///________Print_______________________________________________________
                                  consumerRef.refresh(buyerCustomerProvider);
                                  consumerRef.refresh(transitionProvider);
                                  consumerRef.refresh(productProvider);
                                  consumerRef.refresh(purchaseTransitionProvider);
                                  consumerRef.refresh(dueTransactionProvider);
                                  consumerRef.refresh(profileDetailsProvider);
                                  finish(context);
                                  EasyLoading.showSuccess('Added Successfully');
                                  // TabletSaleInvoice(transitionModel: widget.transitionModel, personalInformationModel: data, isTabPosScreen: true,).launch(context);
                                } catch (e) {
                                  EasyLoading.dismiss();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                }
                              }
                            },
                          ),
                        ],
                      ),
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
      },
    );
  }

  void getSpecificCustomers({required String phoneNumber, required int due}) async {
    final userId = await getUserID();
    final ref = FirebaseDatabase.instance.ref('$userId/Customers/');
    String? key;

    await FirebaseDatabase.instance.ref(userId).child('Customers').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['phoneNumber'] == phoneNumber) {
          key = element.key;
        }
      }
    });
    var data1 = await ref.child('$key/due').get();
    int previousDue = data1.value.toString().toInt();

    int totalDue = previousDue + due;
    ref.child(key!).update({'due': '$totalDue'});
  }

  void decreaseStock(String productCode, num quantity) async {
    final ref = FirebaseDatabase.instance.ref('${await getUserID()}/Products/');

    var data = await ref.orderByChild('productCode').equalTo(productCode).once();
    String productPath = data.snapshot.value.toString().substring(1, 21);

    var data1 = await ref.child('$productPath/productStock').get();
    num stock = int.parse(data1.value.toString());
    num remainStock = stock - quantity;

    ref.child(productPath).update({'productStock': '$remainStock'});
  }
}
