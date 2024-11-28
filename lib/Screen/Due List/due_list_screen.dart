// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/Widgets/noDataFound.dart';
import 'package:salespro_admin/commas.dart';
import 'package:salespro_admin/model/customer_model.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../Provider/customer_provider.dart';
import '../../const.dart';
import '../../currency.dart';
import '../../subscription.dart';
import '../Widgets/Constant Data/export_button.dart';
import '../Widgets/Footer/footer.dart';
import 'due_popUp.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';

class DueList extends StatefulWidget {
  const DueList({Key? key}) : super(key: key);

  static const String route = '/Due_List';

  @override
  State<DueList> createState() => _DueListState();
}

class _DueListState extends State<DueList> {
  double totalCustomerDue({required List<CustomerModel> customers, required String selectedCustomerType}) {
    double totalDue = 0;
    for (var c in customers) {
      totalDue += double.parse(c.dueAmount);
      // if (c.type == selectedCustomerType) {
      //
      // }
    }

    // if (selectedCustomerType != 'All') {
    //   for (var c in customers) {
    //     if (c.type == selectedCustomerType) {
    //       totalDue += double.parse(c.dueAmount);
    //     }
    //   }
    // } else {
    //   for (var c in customers) {
    //     if (c.type != 'Supplier') {
    //       totalDue += double.parse(c.dueAmount);
    //     }
    //   }
    // }
    return totalDue;
  }

  int selectedItem = 10;
  int itemCount = 10;
  String selectedParties = 'Customers';
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
                AsyncValue<List<CustomerModel>> customers = ref.watch(allCustomerProvider);
                return customers.when(data: (allCustomerList) {
                  List<CustomerModel> customerList = [];
                  List<CustomerModel> supplierList = [];
                  List<CustomerModel> showAbleCustomer = [];
                  List<CustomerModel> showAbleSupplier = [];
                  for (var value1 in allCustomerList) {
                    if (value1.type != 'Supplier' && value1.dueAmount.toDouble() > 0) {
                      customerList.add(value1);
                    } else {
                      value1.dueAmount.toDouble() > 0 ? supplierList.add(value1) : null;
                    }
                  }

                  ///___________customer_filter______________________________________________________
                  for (var element in customerList) {
                    if (element.customerName.removeAllWhiteSpace().toLowerCase().contains(searchItem.toLowerCase()) || element.phoneNumber.contains(searchItem)) {
                      showAbleCustomer.add(element);
                    } else if (searchItem == '') {
                      showAbleCustomer.add(element);
                    }
                  }

                  ///___________Suppiler_filter______________________________________________________
                  for (var element in supplierList) {
                    if (element.customerName.removeAllWhiteSpace().toLowerCase().contains(searchItem.toLowerCase()) || element.phoneNumber.contains(searchItem)) {
                      showAbleSupplier.add(element);
                    } else if (searchItem == '') {
                      showAbleSupplier.add(element);
                    }
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 240,
                        child: SideBarWidget(
                          index: 7,
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
                                padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: kWhite,
                                  ),
                                  child: Row(
                                    children: [
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
                                              '${myFormat.format(double.tryParse(totalCustomerDue(customers: selectedParties == 'Customers' ? showAbleCustomer : showAbleSupplier, selectedCustomerType: selectedParties).toStringAsFixed(2)) ?? 0)} $currency',
                                              style: kTextStyle.copyWith(
                                                color: kTitleColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              lang.S.of(context).totalDue,
                                              style: kTextStyle.copyWith(color: kTitleColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: kWhite),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            selectedParties == 'Customers' ? 'Lista de Pedentes (Clientes)' : 'Lista de Pedentes (Fornecedores)',
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
                                              decoration: InputDecoration(
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
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: (() {
                                                  setState(() {
                                                    selectedParties = 'Customers';
                                                  });
                                                }),
                                                child: Container(
                                                  height: 40,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    color: selectedParties == 'Customers' ? kBlueTextColor : Colors.white,
                                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                    border: Border.all(width: 1, color: selectedParties == 'Customers' ? kBlueTextColor : Colors.grey),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      lang.S.of(context).customers,
                                                      style: TextStyle(
                                                        color: selectedParties == 'Customers' ? Colors.white : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              GestureDetector(
                                                onTap: (() {
                                                  setState(() {
                                                    selectedParties = 'Suppliers';
                                                  });
                                                }),
                                                child: Container(
                                                  height: 40,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    color: selectedParties == 'Suppliers' ? kBlueTextColor : Colors.white,
                                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                    border: Border.all(width: 1, color: selectedParties == 'Suppliers' ? kBlueTextColor : Colors.grey),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      lang.S.of(context).supplier,
                                                      style: TextStyle(
                                                        color: selectedParties == 'Suppliers' ? Colors.white : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      Divider(
                                        thickness: 1.0,
                                        color: kGreyTextColor.withOpacity(0.2),
                                      ),

                                      ///__________customer_list_________________________________________________________
                                      // const SizedBox(height: 20.0),
                                      // SizedBox(
                                      //   width: double.infinity,
                                      //   child: DataTable(
                                      //     headingRowColor: MaterialStateProperty.all(kLitGreyColor),
                                      //     showBottomBorder: false,
                                      //     dataTextStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                      //     headingTextStyle: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                      //     columns: const [
                                      //       DataColumn(label: Text('S.L')),
                                      //       DataColumn(label: Text('Name')),
                                      //       DataColumn(label: Text('Party type')),
                                      //       DataColumn(label: Text('Phone')),
                                      //       DataColumn(label: Text('Email')),
                                      //       DataColumn(label: Text('Due')),
                                      //       DataColumn(label: Text('Action')),
                                      //     ],
                                      //     rows: List.generate(
                                      //       selectedParties == 'Suppliers' ? supplierList.length : customerList.length,
                                      //       (index) => DataRow(cells: [
                                      //         DataCell(Text((index + 1).toString())),
                                      //         DataCell(
                                      //           Text(
                                      //             selectedParties == 'Suppliers' ? supplierList[index].customerName : customerList[index].customerName,
                                      //             maxLines: 2,
                                      //             overflow: TextOverflow.ellipsis,
                                      //           ),
                                      //         ),
                                      //         DataCell(
                                      //           Text(selectedParties == 'Suppliers' ? supplierList[index].type : customerList[index].type),
                                      //         ),
                                      //         DataCell(
                                      //             Text(selectedParties == 'Suppliers' ? supplierList[index].phoneNumber : customerList[index].phoneNumber)),
                                      //         DataCell(Text(
                                      //           selectedParties == 'Suppliers' ? supplierList[index].emailAddress : customerList[index].emailAddress,
                                      //           maxLines: 2,
                                      //           overflow: TextOverflow.ellipsis,
                                      //         )),
                                      //         DataCell(Text(selectedParties == 'Suppliers' ? supplierList[index].dueAmount : customerList[index].dueAmount)),
                                      //         DataCell(
                                      //           GestureDetector(
                                      //             onTap: () {
                                      //               showDialog(
                                      //                 barrierDismissible: false,
                                      //                 context: context,
                                      //                 builder: (BuildContext context) {
                                      //                   return StatefulBuilder(
                                      //                     builder: (context, setStates) {
                                      //                       return Dialog(
                                      //                         shape: RoundedRectangleBorder(
                                      //                           borderRadius: BorderRadius.circular(5.0),
                                      //                         ),
                                      //                         child: ShowDuePaymentPopUp(
                                      //                           customerModel: selectedParties == 'Suppliers' ? supplierList[index] : customerList[index],
                                      //                         ),
                                      //                       );
                                      //                     },
                                      //                   );
                                      //                 },
                                      //               );
                                      //             },
                                      //             child: const Text(
                                      //               'Collect Due >',
                                      //               style: TextStyle(color: Colors.blue),
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ]),
                                      //     ),
                                      //   ),
                                      // ),
                                      const SizedBox(height: 20.0),
                                      selectedParties == 'Suppliers' && showAbleSupplier.isNotEmpty || selectedParties != 'Suppliers' && showAbleCustomer.isNotEmpty
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
                                                      ///SizedBox(width: 75, child: Text(lang.S.of(context).partyType)),
                                                      SizedBox(width: 100, child: Text(lang.S.of(context).phone)),
                                                      SizedBox(width: 150, child: Text(lang.S.of(context).email)),
                                                      SizedBox(width: 70, child: Text('Devendo')),
                                                      SizedBox(width: 100, child: Text(lang.S.of(context).collectDue)),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: (MediaQuery.of(context).size.height - 315).isNegative ? 0 : MediaQuery.of(context).size.height - 315,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics: const AlwaysScrollableScrollPhysics(),
                                                    itemCount: selectedParties == 'Suppliers' ? showAbleSupplier.length : showAbleCustomer.length,
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
                                                                    selectedParties == 'Suppliers' ? showAbleSupplier[index].customerName : showAbleCustomer[index].customerName,
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                                                  ),
                                                                ),

                                                                ///____________type_________________________________________________


                                                                ///______Phone___________________________________________________________
                                                                SizedBox(
                                                                  width: 100,
                                                                  child: Text(
                                                                    selectedParties == 'Suppliers' ? showAbleSupplier[index].phoneNumber : showAbleCustomer[index].phoneNumber,
                                                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),

                                                                ///___________Email____________________________________________________
                                                                SizedBox(
                                                                  width: 150,
                                                                  child: Text(
                                                                    selectedParties == 'Suppliers' ? showAbleSupplier[index].emailAddress : showAbleCustomer[index].emailAddress,
                                                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),

                                                                ///___________Due____________________________________________________

                                                                SizedBox(
                                                                  width: 70,
                                                                  child: Text(
                                                                    selectedParties == 'Suppliers'
                                                                        ? myFormat.format(double.tryParse(showAbleSupplier[index].dueAmount) ?? 0)
                                                                        : myFormat.format(double.tryParse(showAbleCustomer[index].dueAmount)),
                                                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),

                                                                ///_______________actions_________________________________________________
                                                                SizedBox(
                                                                  width: 100,
                                                                  child: GestureDetector(
                                                                    onTap: () async {
                                                                      if (await Subscription.subscriptionChecker(item: 'Due List')) {
                                                                        showDialog(
                                                                          barrierDismissible: false,
                                                                          context: context,
                                                                          builder: (BuildContext context) {
                                                                            return StatefulBuilder(
                                                                              builder: (context, setStates) {
                                                                                return Dialog(
                                                                                  surfaceTintColor: Colors.white,
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                                  ),
                                                                                  child: ShowDuePaymentPopUp(
                                                                                    customerModel:
                                                                                        selectedParties == 'Suppliers' ? showAbleSupplier[index] : showAbleCustomer[index],
                                                                                  ),
                                                                                );
                                                                              },
                                                                            );
                                                                          },
                                                                        );
                                                                      } else {
                                                                        EasyLoading.showError('Atualize seu plano primeiro,\no limite de cobrança expirou.');
                                                                      }
                                                                    },
                                                                    child: const Text(
                                                                      'Cobrar divida >',
                                                                      style: TextStyle(color: Colors.blue),
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
                                          : EmptyWidget(title: lang.S.of(context).noDueTransantionFound)
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
          )),
    );
  }
}
