// ignore_for_file: use_build_context_synchronously, unused_result

import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/commas.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../Provider/customer_provider.dart';
import '../../Provider/daily_transaction_provider.dart';
import '../../Provider/due_transaction_provider.dart';
import '../../Provider/profile_provider.dart';
import '../../Provider/transactions_provider.dart';
import '../../const.dart';
import '../../currency.dart';
import '../../model/customer_model.dart';
import '../../model/daily_transaction_model.dart';
import '../../model/due_transaction_model.dart';
import '../../subscription.dart';
import '../Widgets/Constant Data/constant.dart';

class ShowDuePaymentPopUp extends StatefulWidget {
  const ShowDuePaymentPopUp({Key? key, required this.customerModel}) : super(key: key);
  final CustomerModel customerModel;

  @override
  State<ShowDuePaymentPopUp> createState() => _ShowDuePaymentPopUpState();
}

class _ShowDuePaymentPopUpState extends State<ShowDuePaymentPopUp> {
  // List of items in our dropdown menu
  List<String> items = ['Fatura a Pagar'];
  int count = 0;

  bool saleButtonClicked = false;

  late DueTransactionModel dueTransactionModel = DueTransactionModel(
    customerName: widget.customerModel.customerName,
    customerPhone: widget.customerModel.phoneNumber,
    customerAddress: widget.customerModel.customerAddress,
    customerType: widget.customerModel.type,
    invoiceNumber: invoice.toString(),
    purchaseDate: DateTime.now().toString(),
    customerGst: widget.customerModel.gst,
  );

  List<String> paymentItem = [
    'Cash',

  ];
  String selectedPaymentOption = 'Cash';

  DropdownButton<String> getOption() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String des in paymentItem) {
      var item = DropdownMenuItem(
        value: des,
        child: Text(
          des,
          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.normal),
        ),
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
  String selectedInvoice = 'Fatura a Pagar';
  String dropdownValue = 'Fatura a Pagar';
  int invoice = 0;

  TextEditingController payingAmountController = TextEditingController();
  TextEditingController changeAmountController = TextEditingController();
  TextEditingController dueAmountController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dueAmount = widget.customerModel.remainedBalance.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    count++;
    return Consumer(
      builder: (context, consumerRef, __) {
        final customerProviderRef = widget.customerModel.type == 'Supplier' ? consumerRef.watch(purchaseTransitionProvider) : consumerRef.watch(transitionProvider);
        final personalData = consumerRef.watch(profileDetailsProvider);

        return personalData.when(data: (data) {
          invoice = data.dueInvoiceCounter;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 642,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///_________title_and_close_button__________________________________________________
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          lang.S.of(context).createPayment,
                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 20.0),
                        ),
                        const Spacer(),
                        const Icon(FeatherIcons.x, color: kTitleColor, size: 25.0).onTap(() => {
                              finish(context),
                            })
                      ],
                    ),
                  ),

                  ///____________________________________________________________________________________
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        ///______________select_invoice_and_pay_box____________________________
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: kWhite, border: Border.all(color: kLitGreyColor)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  customerProviderRef.when(data: (customer) {
                                    for (var element in customer) {
                                      if (element.customerPhone == widget.customerModel.phoneNumber && element.dueAmount != 0 && count < 2) {
                                        items.add(element.invoiceNumber);
                                      }
                                      if (selectedInvoice == element.invoiceNumber) {
                                        dueAmount = element.dueAmount!.toDouble();
                                      } else if (selectedInvoice == 'Fatura a Pagar') {
                                        dueAmount = widget.customerModel.remainedBalance.toDouble();
                                      }
                                    }
                                    return Container(
                                      height: 40,
                                      width: 180,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(05),
                                        ),
                                        border: Border.all(width: 1, color: Colors.grey),
                                      ),
                                      child: Center(
                                        child: Theme(
                                          data: ThemeData(highlightColor: dropdownItemColor, focusColor: dropdownItemColor, hoverColor: dropdownItemColor),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton(
                                              value: dropdownValue,
                                              icon: const Icon(Icons.keyboard_arrow_down),
                                              items: items.map((String items) {
                                                return DropdownMenuItem(
                                                  value: items,
                                                  child: Text(items, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.normal)),
                                                );
                                              }).toList(),
                                              onChanged: (newValue) {
                                                setState(() {
                                                  payingAmountController.text = '0';
                                                  payingAmountController.clear();
                                                  dropdownValue = newValue.toString();
                                                  selectedInvoice = newValue.toString();
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }, error: (e, stack) {
                                    return Text(e.toString());
                                  }, loading: () {
                                    return const Center(child: CircularProgressIndicator());
                                  }),
                                  const SizedBox(width: 20),
                                  Container(
                                    width: 400,
                                    height: 40,
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                                      color: kbgColor,
                                      border: Border.all(color: kbgColor),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          lang.S.of(context).grandTotal,
                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${myFormat.format(double.tryParse(dueAmount.toString()) ?? 0)} $currency',
                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      lang.S.of(context).payingAmount,
                                      style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 400,
                                    child: AppTextField(
                                      controller: payingAmountController,
                                      onChanged: (value) {
                                        setState(() {
                                          double paidAmount = double.parse(value);
                                          if (paidAmount > dueAmount) {
                                            changeAmountController.text = (paidAmount - dueAmount).toString();
                                            dueAmountController.text = '0';
                                          } else {
                                            dueAmountController.text = (dueAmount - paidAmount).abs().toString();
                                            changeAmountController.text = '0';
                                          }
                                        });
                                      },
                                      showCursor: true,
                                      cursorColor: kTitleColor,
                                      textFieldType: TextFieldType.NAME,
                                      decoration: kInputDecoration.copyWith(
                                        hintText: lang.S.of(context).enterPaidAmount,
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
                                  SizedBox(
                                    width: 400,
                                    child: AppTextField(
                                      readOnly: true,
                                      controller: changeAmountController,
                                      cursorColor: kTitleColor,
                                      textFieldType: TextFieldType.NAME,
                                      decoration: kInputDecoration.copyWith(
                                        hintText: lang.S.of(context).changeAmount,
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
                                      'Valor remanescente',
                                      style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 400,
                                    child: AppTextField(
                                      readOnly: true,
                                      controller: dueAmountController,
                                      cursorColor: kTitleColor,
                                      textFieldType: TextFieldType.NAME,
                                      decoration: kInputDecoration.copyWith(
                                        hintText: lang.S.of(context).dueAmount,
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
                                          child: Theme(
                                              data: ThemeData(highlightColor: dropdownItemColor, focusColor: dropdownItemColor, hoverColor: dropdownItemColor),
                                              child: DropdownButtonHideUnderline(child: getOption())),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20.0),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                      )).onTap(() => {
                                        finish(context),
                                      }),
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
                                    saleButtonClicked
                                        ? () {}
                                        : () async {
                                            if (dueAmount > 0 && !payingAmountController.text.isEmptyOrNull && payingAmountController.text.toInt() > 0) {
                                              try {
                                                setState(() {
                                                  saleButtonClicked = true;
                                                });
                                                EasyLoading.show(status: 'Processando...', dismissOnTap: false);
                                                DatabaseReference ref = FirebaseDatabase.instance.ref("${await getUserID()}/Due Transaction");

                                                dueTransactionModel.totalDue = dueAmount;
                                                dueTransactionModel.sellerName = isSubUser ? constSubUserTitle : 'Admin';
                                                dueAmountController.text.toDouble() <= 0 ? dueTransactionModel.isPaid = true : dueTransactionModel.isPaid = false;
                                                dueAmountController.text.toDouble() <= 0
                                                    ? {dueTransactionModel.dueAmountAfterPay = 0, dueTransactionModel.payDueAmount = dueAmount}
                                                    : {
                                                        dueTransactionModel.dueAmountAfterPay = dueAmountController.text.toDouble(),
                                                        dueTransactionModel.payDueAmount = dueAmount - dueAmountController.text.toDouble()
                                                      };

                                                dueTransactionModel.paymentType = selectedPaymentOption;
                                                await ref.push().set(dueTransactionModel.toJson());

                                                ///_____UpdateInvoice__________________________________________________
                                                selectedInvoice != 'Fatura a Pagar'
                                                    ? updateDueInvoice(
                                                        type: widget.customerModel.type,
                                                        invoice: selectedInvoice.toString(),
                                                        remainDueAmount: dueAmountController.text.toInt(),
                                                      )
                                                    : null;

                                                ///________daily_transactionModel_________________________________________________________________________

                                                if (dueTransactionModel.customerType == 'Supplier') {
                                                  DailyTransactionModel dailyTransaction = DailyTransactionModel(
                                                    name: dueTransactionModel.customerName,
                                                    date: dueTransactionModel.purchaseDate,
                                                    type: 'Due Payment',
                                                    total: dueTransactionModel.totalDue!.toDouble(),
                                                    paymentIn: 0,
                                                    paymentOut: dueTransactionModel.totalDue!.toDouble() - dueTransactionModel.dueAmountAfterPay!.toDouble(),
                                                    remainingBalance: dueTransactionModel.totalDue!.toDouble() - dueTransactionModel.dueAmountAfterPay!.toDouble(),
                                                    id: dueTransactionModel.invoiceNumber,
                                                    dueTransactionModel: dueTransactionModel,
                                                  );
                                                  postDailyTransaction(dailyTransactionModel: dailyTransaction);
                                                } else {
                                                  DailyTransactionModel dailyTransaction = DailyTransactionModel(
                                                    name: dueTransactionModel.customerName,
                                                    date: dueTransactionModel.purchaseDate,
                                                    type: 'Due Collection',
                                                    total: dueTransactionModel.totalDue!.toDouble(),
                                                    paymentIn: dueTransactionModel.totalDue!.toDouble() - dueTransactionModel.dueAmountAfterPay!.toDouble(),
                                                    paymentOut: 0,
                                                    remainingBalance: dueTransactionModel.totalDue!.toDouble() - dueTransactionModel.dueAmountAfterPay!.toDouble(),
                                                    id: dueTransactionModel.invoiceNumber,
                                                    dueTransactionModel: dueTransactionModel,
                                                  );
                                                  postDailyTransaction(dailyTransactionModel: dailyTransaction);
                                                }

                                                ///_________DueUpdate______________________________________________________
                                                final cRef = FirebaseDatabase.instance.ref('${await getUserID()}/Customers/');
                                                String? key;

                                                await FirebaseDatabase.instance.ref(await getUserID()).child('Customers').orderByKey().get().then((value) {
                                                  for (var element in value.children) {
                                                    var data = jsonDecode(jsonEncode(element.value));
                                                    if (data['phoneNumber'] == widget.customerModel.phoneNumber) {
                                                      key = element.key;
                                                    }
                                                  }
                                                });
                                                var data1 = await cRef.child('$key/due').get();
                                                var data2 = await cRef.child('$key/remainedBalance').get();
                                                int previousDue = data1.value.toString().toInt();
                                                int remainedBalance = data2.value.toString().toInt();

                                                int totalDue = previousDue - dueTransactionModel.payDueAmount!.toInt();
                                                int remainedDue = remainedBalance - dueTransactionModel.payDueAmount!.toInt();
                                                cRef.child(key!).update({'due': '$totalDue'});
                                                selectedInvoice == 'Fatura a Pagar' ? cRef.child(key!).update({'remainedBalance': '$remainedDue'}) : null;

                                                ///_________Invoice Increase____________________________________________________________________________
                                                updateInvoice(
                                                  typeOfInvoice: 'dueInvoiceCounter',
                                                  invoice: data.dueInvoiceCounter.toInt(),
                                                );

                                                ///________Subscription_____________________________________________________
                                                Subscription.decreaseSubscriptionLimits(itemType: 'dueNumber', context: context);

                                                consumerRef.refresh(allCustomerProvider);
                                                consumerRef.refresh(transitionProvider);
                                                consumerRef.refresh(purchaseTransitionProvider);
                                                consumerRef.refresh(dueTransactionProvider);
                                                consumerRef.refresh(profileDetailsProvider);
                                                consumerRef.refresh(dailyTransactionProvider);

                                                finish(context);
                                                EasyLoading.showSuccess('Operação realizada com sucesso');
                                              } catch (e) {
                                                setState(() {
                                                  saleButtonClicked = false;
                                                });
                                                EasyLoading.dismiss();
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                              }
                                            } else if (dueAmount <= 0) {
                                              EasyLoading.showError('Selecione uma fatura');
                                            } else if (payingAmountController.text.isEmptyOrNull || payingAmountController.text.toInt() <= 0) {
                                              EasyLoading.showError('Por favor insira o valor');
                                            }
                                          },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

  void updateDueInvoice({required String type, required String invoice, required int remainDueAmount}) async {
    final ref =
        type == 'Supplier' ? FirebaseDatabase.instance.ref('${await getUserID()}/Purchase Transition/') : FirebaseDatabase.instance.ref('${await getUserID()}/Sales Transition/');
    String? key;

    type == 'Supplier'
        ? await FirebaseDatabase.instance.ref(await getUserID()).child('Purchase Transition/').orderByKey().get().then((value) {
            for (var element in value.children) {
              var data = jsonDecode(jsonEncode(element.value));
              if (data['invoiceNumber'] == invoice) {
                key = element.key;
              }
            }
          })
        : await FirebaseDatabase.instance.ref(await getUserID()).child('Sales Transition').orderByKey().get().then((value) {
            for (var element in value.children) {
              var data = jsonDecode(jsonEncode(element.value));
              if (data['invoiceNumber'] == invoice) {
                key = element.key;
              }
            }
          });
    ref.child(key!).update({
      'dueAmount': '$remainDueAmount',
    });
  }
}
