import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Provider/profile_provider.dart';
import 'package:salespro_admin/commas.dart';
import 'package:salespro_admin/model/personal_information_model.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../PDF/print_pdf.dart';
import '../../Provider/customer_provider.dart';
import '../../Provider/purchase_transaction_single.dart';
import '../../Provider/transactions_provider.dart';
import '../../const.dart';
import '../../currency.dart';
import '../../model/customer_model.dart';
import '../../model/purchase_transation_model.dart';
import '../../model/sale_transaction_model.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Constant Data/export_button.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({
    super.key,
  });

  static const String route = '/ledger';

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  double singleCustomersTotalSaleAmount({required List<SaleTransactionModel> allTransitions, required String customerPhoneNumber}) {
    double totalSale = 0;
    for (var transition in allTransitions) {
      if (transition.customerPhone == customerPhoneNumber) {
        totalSale += transition.totalAmount!.toDouble();
      }
    }
    return totalSale;
  }

  double singleSupplierTotalSaleAmount({required List<dynamic> allTransitions, required String customerPhoneNumber}) {
    double totalSale = 0;
    for (var transition in allTransitions) {
      if (transition.customerPhone == customerPhoneNumber) {
        totalSale += transition.totalAmount!.toDouble();
      }
    }
    return totalSale;
  }

  double totalSale({required List<SaleTransactionModel> allTransitions, required String selectedCustomerType}) {
    double totalSale = 0;

    if (selectedCustomerType != 'Todos') {
      for (var transition in allTransitions) {
        if (transition.customerType == selectedCustomerType) {
          totalSale += transition.totalAmount!.toDouble();
        }
      }
    } else {
      for (var transition in allTransitions) {
        totalSale += transition.totalAmount!.toDouble();
      }
    }

    return totalSale;
  }

  double totalPurchase({required List<dynamic> allTransitions}) {
    double totalPurchase = 0;

    for (var transition in allTransitions) {
      totalPurchase += transition.totalAmount!.toDouble();
    }
    return totalPurchase;
  }

  double totalCustomerDue({required List<CustomerModel> customers, required String selectedCustomerType}) {
    double totalDue = 0;

    if (selectedCustomerType != 'Todos') {
      for (var c in customers) {
        if (c.type == selectedCustomerType) {
          totalDue += double.parse(c.dueAmount);
        }
      }
    } else {
      for (var c in customers) {
        if (c.type != 'Supplier') {
          totalDue += double.parse(c.dueAmount);
        }
      }
    }
    return totalDue;
  }

  double totalSupplierDue({required List<CustomerModel> customers}) {
    double totalDue = 0;

    for (var c in customers) {
      if (c.type == 'Supplier') {
        totalDue += double.parse(c.dueAmount);
      }
    }
    return totalDue;
  }

  double totalCustomerReceivedAmount({required List<SaleTransactionModel> allTransitions, required String selectedCustomerType}) {
    double totalReceived = 0;

    if (selectedCustomerType != 'Todos') {
      for (var transition in allTransitions) {
        if (transition.customerType == selectedCustomerType) {
          totalReceived += transition.totalAmount!.toDouble() - transition.dueAmount!.toDouble();
        }
      }
    } else {
      for (var transition in allTransitions) {
        totalReceived += transition.totalAmount!.toDouble() - transition.dueAmount!.toDouble();
      }
    }
    return totalReceived;
  }

  List<CustomerModel> listOfSelectedCustomers = [];

  String selectedLedgerItems = 'Todos';
  List<String> allPartis = ['Todos', 'Retailer', 'Distribuidora', 'Atacado', 'Supplier',];
  int counter = 0;
  ScrollController mainScroll = ScrollController();
  String searchItem = '';
  TextEditingController search = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkCurrentUserAndRestartApp();
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
            final saleTransactionReport = ref.watch(transitionProvider);
            final purchaseTransactionReport = ref.watch(purchaseTransitionProviderSIngle);

            final allCustomers = ref.watch(allCustomerProvider);
            final personalDetails = ref.watch(profileDetailsProvider);

            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 240,
                  child: SideBarWidget(
                    index: 8,
                    isTab: false,
                  ),
                ),
                allCustomers.when(data: (allCustomers) {
                  counter == 0 ? listOfSelectedCustomers = List.from(allCustomers) : null;
                  counter++;
                  return Container(
                    // width: context.width() < 1080 ? 1080 - 240 : MediaQuery.of(context).size.width - 240,
                    width: MediaQuery.of(context).size.width < 1275 ? 1275 - 240 : MediaQuery.of(context).size.width - 240,
                    decoration: const BoxDecoration(color: kDarkWhite),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                              color: kWhite,
                            ),
                            child: const TopBar(),
                          ),

                          ///_______All_totals__________________________________________________________
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: kWhite,
                              ),
                              child: Row(
                                children: [
                                  ///________Total Sale____________________________________________
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
                                          '${myFormat.format(double.parse(totalSale(allTransitions: saleTransactionReport.value!, selectedCustomerType: selectedLedgerItems).toStringAsFixed(2)) ?? 0)} $currency',
                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                        ),
                                        Text(
                                          lang.S.of(context).totalSale,
                                          style: kTextStyle.copyWith(color: kTitleColor),
                                        ),
                                      ],
                                    ),
                                  ).visible(selectedLedgerItems != 'Supplier'),
                                  const SizedBox(width: 10.0),

                                  ///________Total_purchase_________________________________________
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
                                          '${myFormat.format(double.tryParse(totalPurchase(allTransitions: purchaseTransactionReport.value!).toStringAsFixed(2)) ?? 0)} $currency',
                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                        ),
                                        Text(
                                          lang.S.of(context).totalPurchase,
                                          style: kTextStyle.copyWith(color: kTitleColor),
                                        ),
                                      ],
                                    ),
                                  ).visible(selectedLedgerItems == 'Supplier' || selectedLedgerItems == 'Todos'),
                                  const SizedBox(width: 10.0),

                                  ///____________Total received Amount_________________________________
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
                                          '${myFormat.format(double.tryParse(totalCustomerReceivedAmount(allTransitions: saleTransactionReport.value!, selectedCustomerType: selectedLedgerItems).toStringAsFixed(2)) ?? 0)} $currency',
                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                        ),
                                        Text(
                                          lang.S.of(context).recivedAmount,
                                          style: kTextStyle.copyWith(color: kTitleColor),
                                        ),
                                      ],
                                    ),
                                  ).visible(selectedLedgerItems != "Supplier"),
                                  const SizedBox(width: 10.0),

                                  ///________total_customer_due___________________________________________________________
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
                                          '${myFormat.format(double.tryParse(totalCustomerDue(customers: allCustomers, selectedCustomerType: selectedLedgerItems).toStringAsFixed(2)) ?? 0)} $currency',
                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                        ),
                                        Text(
                                          lang.S.of(context).customerDue,
                                          style: kTextStyle.copyWith(color: kTitleColor),
                                        ),
                                      ],
                                    ),
                                  ).visible(selectedLedgerItems != "Supplier"),
                                  const SizedBox(width: 10.0),

                                  ///________total_Supplier_due___________________________________________________________
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
                                          '${myFormat.format(double.tryParse(totalSupplierDue(customers: allCustomers).toStringAsFixed(2)) ?? 0)} $currency',
                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                        ),
                                        Text(
                                          lang.S.of(context).supplierDue,
                                          style: kTextStyle.copyWith(color: kTitleColor),
                                        ),
                                      ],
                                    ),
                                  ).visible(selectedLedgerItems == "Supplier" || selectedLedgerItems == "Todos"),
                                  const SizedBox(width: 10.0),
                                ],
                              ),
                            ),
                          ),

                          ///____________Customers_List_Bord____________________________________________
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
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 300,
                                          height: 40,
                                          child: FormField(
                                            builder: (FormFieldState<dynamic> field) {
                                              return InputDecorator(
                                                decoration: InputDecoration(
                                                  enabledBorder: const OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                    borderSide: BorderSide(color: kBorderColorTextField, width: 2),
                                                  ),
                                                  contentPadding: const EdgeInsets.all(8.0),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                  labelText: lang.S.of(context).selectParties,
                                                ),
                                                child: Theme(
                                                  data: ThemeData(highlightColor: dropdownItemColor, focusColor: dropdownItemColor, hoverColor: dropdownItemColor),
                                                  child: DropdownButtonHideUnderline(
                                                    child: DropdownButton<String>(
                                                      onChanged: (String? value) {
                                                        listOfSelectedCustomers.clear();
                                                        setState(() {
                                                          selectedLedgerItems = value!;

                                                          for (var element in allCustomers) {
                                                            if (selectedLedgerItems == 'Todos') {
                                                              listOfSelectedCustomers.add(element);
                                                            } else {
                                                              if (element.type == selectedLedgerItems) {
                                                                listOfSelectedCustomers.add(element);
                                                              }
                                                            }
                                                          }
                                                          searchItem = '';
                                                          search.clear();
                                                          toast(selectedLedgerItems);
                                                        });
                                                      },
                                                      value: selectedLedgerItems,
                                                      items: allPartis.map((String items) {
                                                        return DropdownMenuItem(
                                                          value: items,
                                                          child: Text(items),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const Spacer(),

                                        ///___________search________________________________________________-
                                        Container(
                                          height: 40.0,
                                          width: 300,
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0), border: Border.all(color: kGreyTextColor.withOpacity(0.1))),
                                          child: AppTextField(
                                            controller: search,
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
                                              hintText: (lang.S.of(context).searchByNameOrPhone),
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
                                  ),

                                  ///___________selected_customer_list__________________________________________
                                  const SizedBox(height: 15.0),
                                  listOfSelectedCustomers.isNotEmpty
                                      ? Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(15),
                                              decoration: const BoxDecoration(color: kbgColor),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  const SizedBox(width: 50, child: Text('Nr')),
                                                  SizedBox(width: 180, child: Text(lang.S.of(context).partyName)),
                                                  ///SizedBox(width: 75, child: Text(lang.S.of(context).partyName)),
                                                  SizedBox(width: 100, child: Text(lang.S.of(context).totalAmount)),
                                                  SizedBox(width: 150, child: Text(lang.S.of(context).dueAmount)),
                                                  SizedBox(width: 100, child: Text(lang.S.of(context).details)),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: (MediaQuery.of(context).size.height - 315).isNegative ? 0 : MediaQuery.of(context).size.height - 315,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                physics: const AlwaysScrollableScrollPhysics(),
                                                itemCount: listOfSelectedCustomers.length,
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

                                                            ///______________name__________________________________________________
                                                            SizedBox(
                                                              width: 180,
                                                              child: Text(
                                                                listOfSelectedCustomers[index].customerName,
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                                              ),
                                                            ),

                                                            ///____________type_________________________________________________

                                                            ///______Amount___________________________________________________________
                                                            SizedBox(
                                                              width: 100,
                                                              child: Text(
                                                                listOfSelectedCustomers[index].type == 'Supplier'
                                                                    ? singleSupplierTotalSaleAmount(
                                                                            allTransitions: purchaseTransactionReport.value!,
                                                                            customerPhoneNumber: listOfSelectedCustomers[index].phoneNumber)
                                                                        .toString()
                                                                    : singleCustomersTotalSaleAmount(
                                                                            allTransitions: saleTransactionReport.value!,
                                                                            customerPhoneNumber: listOfSelectedCustomers[index].phoneNumber)
                                                                        .toStringAsFixed(2),
                                                                style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),

                                                            ///___________Due____________________________________________________

                                                            SizedBox(
                                                              width: 150,
                                                              child: Text(
                                                                myFormat.format(double.tryParse(listOfSelectedCustomers[index].dueAmount.toString()) ?? 0),
                                                                // selectedParties == 'Suppliers' ? supplierList[index].dueAmount : customerList[index].dueAmount,
                                                                style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),

                                                            ///_______________actions_________________________________________________
                                                            SizedBox(
                                                              width: 100,
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  ledgerDetails(
                                                                    transitionModel: saleTransactionReport.value!,
                                                                    customer: listOfSelectedCustomers[index],
                                                                    personalInformationModel: personalDetails.value!,
                                                                    purchaseTransactionReport: purchaseTransactionReport.value ?? [],
                                                                  );
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
                                                  ).visible(
                                                    listOfSelectedCustomers[index].customerName.toLowerCase().contains(searchItem.toLowerCase()) ||
                                                        listOfSelectedCustomers[index].phoneNumber.toLowerCase().contains(searchItem.toLowerCase()),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      : EmptyWidget(title: lang.S.of(context).noTransactionFound)
                                ],
                              ),
                            ),
                          ),
                          Visibility(visible: MediaQuery.of(context).size.height != 0, child: const Footer()),
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
                }),
              ],
            );
          }),
        ),
      ),
    );
  }

  void ledgerDetails({
    required List<SaleTransactionModel> transitionModel,
    required CustomerModel customer,
    required PersonalInformationModel personalInformationModel,
    required List<PurchaseTransactionModel> purchaseTransactionReport,
  }) {
    double totalSale = 0;
    double totalPurchase = 0;
    double totalReceive = 0;
    double totalPaid = 0;
    List<SaleTransactionModel> transitions = [];
    List<PurchaseTransactionModel> purchaseTransitions = [];
    List<String> dayLimits = [
      'All',
      '7',
      '15',
      '30',
    ];
    String selectedDate = 'All';
    for (var element in transitionModel) {
      if (element.customerPhone == customer.phoneNumber) {
        transitions.add(element);
        totalSale += element.totalAmount!.toDouble();
        totalReceive += element.totalAmount!.toDouble() - element.dueAmount!.toDouble();
      }
    }
    for (var element in purchaseTransactionReport) {
      if (element.customerPhone == customer.phoneNumber) {
        purchaseTransitions.add(element);
        totalPurchase += element.totalAmount!.toDouble();
        totalPaid += element.totalAmount!.toDouble() - element.dueAmount!.toDouble();
      }
    }

    bool isInTime({required int day, required String date}) {
      if (DateTime.parse(date).isAfter(DateTime.now().subtract(Duration(days: day)))) {
        return true;
      } else if (date == 'All') {
        return true;
      } else {
        return false;
      }
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              surfaceTintColor: kWhite,
              backgroundColor: kWhite,
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
                                'Registros',
                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 20.0),
                              ),
                              const Spacer(),
                              const Icon(FeatherIcons.x, color: kTitleColor, size: 25.0).onTap(() => {finish(context)})
                            ],
                          ),
                        ),
                        const Divider(thickness: 1.0, color: kLitGreyColor),

                        ///_______All_totals__________________________________________________________
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: kWhite,
                          ),
                          child: Row(
                            children: [
                              ///________Total Sale____________________________________________
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
                                      '${myFormat.format(double.tryParse(customer.type == 'Supplier' ? totalPurchase.toString() : totalSale.toString()) ?? 0)} $currency',
                                      style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                    ),
                                    Text(
                                      customer.type == 'Supplier' ? "Compras Totais" : 'Vendas Totais',
                                      style: kTextStyle.copyWith(color: kTitleColor),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10.0),

                              ///____________Total received Amount_________________________________
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
                                      '${myFormat.format(double.tryParse(customer.type == 'Supplier' ? totalPaid.toString() : totalReceive.toString()) ?? 0)} $currency',
                                      style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                    ),
                                    Text(
                                      customer.type == 'Supplier' ? 'Valor Pago' : 'Valor Recebido',
                                      style: kTextStyle.copyWith(color: kTitleColor),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10.0),

                              ///________total_customer_due___________________________________________________________
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
                                      '${myFormat.format(double.tryParse(customer.dueAmount) ?? 0)} $currency',
                                      style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                    ),
                                    Text(
                                      'Total Devido',
                                      style: kTextStyle.copyWith(color: kTitleColor),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10.0),

                              ///________opening balance___________________________________________________________
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
                                      '${myFormat.format(double.tryParse(customer.remainedBalance) ?? 0)} $currency',
                                      style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                    ),
                                    Text(
                                      'Saldo inicial',
                                      style: kTextStyle.copyWith(color: kTitleColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        const Divider(thickness: 1.0, color: kLitGreyColor),
                        const SizedBox(height: 10),
                        Text('Nome: ${customer.customerName}'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text('Telefone: ${customer.phoneNumber}'),
                            const Spacer(),
                            SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                                    backgroundColor: kMainColor,
                                    side: const BorderSide(color: kMainColor, width: 1),
                                    textStyle: kTextStyle.copyWith(color: Colors.white),
                                    surfaceTintColor: kMainColor,
                                    shadowColor: kMainColor.withOpacity(0.1),
                                    foregroundColor: kMainColor.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                                onPressed: () async {
                                  if (customer.type != 'Supplier') {
                                    await GeneratePdfAndPrint()
                                        .printSaleLedger(personalInformationModel: personalInformationModel, saleTransactionModel: transitions, customer: customer);
                                  } else {
                                    await GeneratePdfAndPrint()
                                        .printPurchaseLedger(personalInformationModel: personalInformationModel, purchaseTransactionModel: purchaseTransitions, customer: customer);
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.print, color: Colors.white, size: 16),
                                    const SizedBox(width: 5.0),
                                    Text(
                                      'Imprimir',
                                      style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(kbgColor),
                            showBottomBorder: false,
                            columnSpacing: 0.0,
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Nr',
                                  style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text('Data', style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: 100.0,
                                  child: Text(
                                    'Fatura',
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Nome',
                                  style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                    width: 100.0,
                                    child: Text(
                                      'Tipo de Pagamento',
                                      style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    )),
                              ),
                              DataColumn(
                                label: Text('Valor', style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                              ),
                              DataColumn(
                                label: Text('Dívida', style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                              ),
                              DataColumn(
                                label: Text('Status', style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                              ),
                              const DataColumn(
                                label: Icon(FeatherIcons.settings, color: kGreyTextColor),
                              ),
                            ],
                            rows: customer.type == 'Supplier'
                                ? List.generate(
                                    purchaseTransitions.length,
                                    (index) {
                                      return DataRow(cells: [
                                        DataCell(
                                          Text((index + 1).toString()),
                                        ),
                                        DataCell(
                                          Text(purchaseTransitions[index].purchaseDate.substring(0, 10), style: kTextStyle.copyWith(color: kGreyTextColor)),
                                        ),
                                        DataCell(
                                          Text(purchaseTransitions[index].invoiceNumber, style: kTextStyle.copyWith(color: kGreyTextColor)),
                                        ),
                                        DataCell(
                                          Text(purchaseTransitions[index].customerName, style: kTextStyle.copyWith(color: kGreyTextColor)),
                                        ),
                                        DataCell(
                                          Text(purchaseTransitions[index].paymentType.toString(), style: kTextStyle.copyWith(color: kGreyTextColor)),
                                        ),
                                        DataCell(
                                          Text(myFormat.format(double.tryParse(purchaseTransitions[index].totalAmount.toString()) ?? 0),
                                              style: kTextStyle.copyWith(color: kGreyTextColor)),
                                        ),
                                        DataCell(
                                          Text(myFormat.format(double.tryParse(purchaseTransitions[index].dueAmount.toString()) ?? 0),
                                              style: kTextStyle.copyWith(color: kGreyTextColor)),
                                        ),
                                        DataCell(
                                          Text(purchaseTransitions[index].isPaid! ? 'Pago' : "Devendo", style: kTextStyle.copyWith(color: kGreyTextColor)),
                                        ),
                                        DataCell(
                                          PopupMenuButton(
                                            icon: const Icon(FeatherIcons.moreVertical, size: 18.0),
                                            padding: EdgeInsets.zero,
                                            itemBuilder: (BuildContext bc) => [
                                              PopupMenuItem(
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    await GeneratePdfAndPrint().printPurchaseInvoice(
                                                        personalInformationModel: personalInformationModel, purchaseTransactionModel: purchaseTransitions[index]);
                                                    // SaleInvoice(
                                                    //   isPosScreen: false,
                                                    //   transitionModel: transitions[index],
                                                    //   personalInformationModel: personalInformationModel,
                                                    // ).launch(context);
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(MdiIcons.printer, size: 18.0, color: kTitleColor),
                                                      const SizedBox(width: 4.0),
                                                      Text(
                                                        'Imprimir',
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
                                      ]);
                                    },
                                  )
                                : List.generate(
                                    transitions.length,
                                    (index) {
                                      return DataRow(cells: [
                                        DataCell(
                                          Text((index + 1).toString()),
                                        ),
                                        DataCell(
                                          Text(transitions[index].purchaseDate.substring(0, 10), style: kTextStyle.copyWith(color: kGreyTextColor)),
                                        ),
                                        DataCell(
                                          Text(transitions[index].invoiceNumber, style: kTextStyle.copyWith(color: kGreyTextColor)),
                                        ),
                                        DataCell(
                                          Text(transitions[index].customerName, style: kTextStyle.copyWith(color: kGreyTextColor)),
                                        ),
                                        DataCell(
                                          Text(transitions[index].paymentType.toString(), style: kTextStyle.copyWith(color: kGreyTextColor)),
                                        ),
                                        DataCell(
                                          Text(myFormat.format(double.tryParse(transitions[index].totalAmount.toString()) ?? 0), style: kTextStyle.copyWith(color: kGreyTextColor)),
                                        ),
                                        DataCell(
                                          Text(myFormat.format(double.tryParse(transitions[index].dueAmount.toString()) ?? 0), style: kTextStyle.copyWith(color: kGreyTextColor)),
                                        ),
                                        DataCell(
                                          Text(transitions[index].isPaid! ? 'Pago' : "Devendo", style: kTextStyle.copyWith(color: kGreyTextColor)),
                                        ),
                                        DataCell(
                                          PopupMenuButton(
                                            icon: const Icon(FeatherIcons.moreVertical, size: 18.0),
                                            padding: EdgeInsets.zero,
                                            itemBuilder: (BuildContext bc) => [
                                              PopupMenuItem(
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    await GeneratePdfAndPrint()
                                                        .printSaleInvoice(personalInformationModel: personalInformationModel, saleTransactionModel: transitions[index]);
                                                    // SaleInvoice(
                                                    //   isPosScreen: false,
                                                    //   transitionModel: transitions[index],
                                                    //   personalInformationModel: personalInformationModel,
                                                    // ).launch(context);
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(MdiIcons.printer, size: 18.0, color: kTitleColor),
                                                      const SizedBox(width: 4.0),
                                                      Text(
                                                        'Imprimir',
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
                                      ]);
                                    },
                                  ),
                          ),
                        ),
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
}
