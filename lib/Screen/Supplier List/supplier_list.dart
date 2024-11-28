import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/Customer%20List/add_customer.dart';
import 'package:salespro_admin/commas.dart';
import 'package:salespro_admin/model/customer_model.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../Provider/customer_provider.dart';
import '../../const.dart';
import '../../subscription.dart';
import '../Customer List/edit_customer.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Constant Data/export_button.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';

class SupplierList extends StatefulWidget {
  const SupplierList({Key? key}) : super(key: key);

  static const String route = '/supplier';

  @override
  State<SupplierList> createState() => _SupplierListState();
}

class _SupplierListState extends State<SupplierList> {
  List<int> item = [
    10,
    20,
    30,
    50,
    80,
    100,
  ];
  int selectedItem = 10;
  int itemCount = 10;

  DropdownButton<int> selectItem() {
    List<DropdownMenuItem<int>> dropDownItems = [];
    for (int des in item) {
      var item = DropdownMenuItem(
        value: des,
        child: Text('${des.toString()} items'),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      items: dropDownItems,
      value: selectedItem,
      onChanged: (value) {
        setState(() {
          selectedItem = value!;
          itemCount = value;
        });
      },
    );
  }

  void deleteCustomer({required String phoneNumber, required WidgetRef updateRef, required BuildContext context}) async {
    EasyLoading.show(status: 'Deleting..');
    String customerKey = '';
    await FirebaseDatabase.instance.ref(await getUserID()).child('Customers').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['phoneNumber'].toString() == phoneNumber) {
          customerKey = element.key.toString();
        }
      }
    });
    DatabaseReference ref = FirebaseDatabase.instance.ref("${await getUserID()}/Customers/$customerKey");
    await ref.remove();
    updateRef.refresh(allCustomerProvider);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    EasyLoading.showSuccess('Done');
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
              AsyncValue<List<CustomerModel>> allCustomers = ref.watch(allCustomerProvider);
              return allCustomers.when(data: (allList) {
                List<CustomerModel> allCustomers = allList.reversed.toList();
                List<String> listOfPhoneNumber = [];
                List<CustomerModel> showAbleSuppliers = [];
                List<CustomerModel> allSupplier = [];

                for (var value1 in allCustomers) {
                  listOfPhoneNumber.add(value1.phoneNumber.removeAllWhiteSpace().toLowerCase());
                  if (value1.type == 'Supplier') {
                    allSupplier.add(value1);
                  }
                }

                for (var element in allSupplier) {
                  if (element.customerName.removeAllWhiteSpace().toLowerCase().contains(searchItem.toLowerCase()) || element.phoneNumber.contains(searchItem)) {
                    showAbleSuppliers.add(element);
                  } else if (searchItem == '') {
                    showAbleSuppliers.add(element);
                  }
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 240,
                      child: SideBarWidget(
                        index: 5,
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
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          lang.S.of(context).supplierList,
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
                                        const SizedBox(width: 20),
                                        Container(
                                          padding: const EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: kBlueTextColor),
                                          child: Row(
                                            children: [
                                              const Icon(FeatherIcons.plus, color: kWhite, size: 18.0),
                                              const SizedBox(width: 5.0),
                                              Text(
                                                'Adicionar Fornecedor',
                                                style: kTextStyle.copyWith(color: kWhite),
                                              ),
                                            ],
                                          ),
                                        ).onTap(() async {
                                          if (await Subscription.subscriptionChecker(item: 'Parties')) {
                                            showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AddCustomer(
                                                    typeOfCustomerAdd: 'Supplier',
                                                    listOfPhoneNumber: listOfPhoneNumber,
                                                    sideBarNumber: 5,
                                                  );
                                                });
                                          } else {
                                            EasyLoading.showError('Atualize seu plano primeiro\nO limite para adicionar fornecedor acabou.');
                                          }
                                        }),
                                      ],
                                    ),
                                    const SizedBox(height: 5.0),
                                    Divider(
                                      thickness: 1.0,
                                      color: kGreyTextColor.withOpacity(0.2),
                                    ),
                                    const SizedBox(height: 20.0),

                                    ///__________list_______________________________________________________________________

                                    const SizedBox(height: 20.0),
                                    showAbleSuppliers.isNotEmpty
                                        ? SizedBox(
                                            height: (MediaQuery.of(context).size.height - 280).isNegative ? 0 : MediaQuery.of(context).size.height - 280,
                                            width: MediaQuery.of(context).size.width < 1275 ? 1275 - 240 : MediaQuery.of(context).size.width - 240,
                                            child: SingleChildScrollView(
                                              child: DataTable(
                                                columnSpacing: 10,
                                                clipBehavior: Clip.antiAlias,
                                                border: TableBorder.lerp(TableBorder(verticalInside: BorderSide.none, borderRadius: BorderRadius.circular(8.0)),
                                                    TableBorder(borderRadius: BorderRadius.circular(8.0)), 8.0),
                                                showCheckboxColumn: true,
                                                dividerThickness: 1.0,
                                                dataRowColor: const MaterialStatePropertyAll(whiteColor),
                                                headingRowColor: MaterialStateProperty.all(const Color(0xFFF8F3FF)),
                                                showBottomBorder: false,
                                                headingTextStyle: kTextStyle.copyWith(color: kTitleColor, overflow: TextOverflow.ellipsis),
                                                dataTextStyle: kTextStyle.copyWith(color: kGreyTextColor, overflow: TextOverflow.ellipsis),
                                                columns: [
                                                  DataColumn(
                                                    label: Text(
                                                      'Nr',
                                                      style: kTextStyle.copyWith(color: kTitleColor, overflow: TextOverflow.ellipsis),
                                                    ),
                                                  ),
                                                  DataColumn(label: Text('Image', style: kTextStyle.copyWith(color: kTitleColor, overflow: TextOverflow.ellipsis))),
                                                  DataColumn(
                                                      label: Flexible(
                                                          child:
                                                              Text('Nome do Fornecedor', style: kTextStyle.copyWith(color: kTitleColor, overflow: TextOverflow.ellipsis)))),

                                                  DataColumn(
                                                      label: Text(lang.S.of(context).phone, style: kTextStyle.copyWith(color: kTitleColor, overflow: TextOverflow.ellipsis))),
                                                  DataColumn(
                                                      label: Text(lang.S.of(context).email, style: kTextStyle.copyWith(color: kTitleColor, overflow: TextOverflow.ellipsis))),
                                                  DataColumn(label: Text(lang.S.of(context).due, style: kTextStyle.copyWith(color: kTitleColor, overflow: TextOverflow.ellipsis))),
                                                  const DataColumn(label: Icon(FeatherIcons.settings)),
                                                ],
                                                rows: List.generate(
                                                  showAbleSuppliers.length,
                                                  (index) => DataRow(
                                                    cells: [
                                                      DataCell(Text(
                                                        (index + 1).toString(),
                                                        style: kTextStyle.copyWith(color: kGreyTextColor),
                                                        textAlign: TextAlign.start,
                                                      )),
                                                      DataCell(Container(
                                                        height: 40,
                                                        width: 40,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          border: Border.all(color: kBorderColorTextField),
                                                          image: DecorationImage(image: NetworkImage(showAbleSuppliers[index].profilePicture), fit: BoxFit.cover),
                                                        ),
                                                      )),
                                                      DataCell(
                                                        Text(
                                                          showAbleSuppliers[index].customerName,
                                                          style: kTextStyle.copyWith(color: kTitleColor),
                                                        ),
                                                      ),
                                                     /// DataCell(
                                                       /// Text(showAbleSuppliers[index].type),
                                                    ///  ),
                                                      DataCell(
                                                        Text(showAbleSuppliers[index].phoneNumber),
                                                      ),
                                                      DataCell(
                                                        Text(showAbleSuppliers[index].emailAddress),
                                                      ),
                                                      DataCell(
                                                        Text(myFormat.format(double.tryParse(showAbleSuppliers[index].dueAmount) ?? 0)),
                                                      ),
                                                      DataCell(
                                                        Theme(
                                                          data: ThemeData(highlightColor: dropdownItemColor, focusColor: dropdownItemColor, hoverColor: dropdownItemColor),
                                                          child: PopupMenuButton(
                                                            surfaceTintColor: Colors.white,
                                                            padding: EdgeInsets.zero,
                                                            itemBuilder: (BuildContext bc) => [
                                                              PopupMenuItem(
                                                                child: Row(
                                                                  children: [
                                                                    const Icon(FeatherIcons.edit3, size: 18.0, color: kTitleColor),
                                                                    const SizedBox(width: 4.0),
                                                                    Text(
                                                                      lang.S.of(context).edit,
                                                                      style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                    ),
                                                                  ],
                                                                ).onTap(() {
                                                                  showDialog(
                                                                      barrierDismissible: false,
                                                                      context: context,
                                                                      builder: (BuildContext context) {
                                                                        return EditCustomer(
                                                                          allPreviousCustomer: allCustomers,
                                                                          customerModel: showAbleSuppliers[index],
                                                                          typeOfCustomerAdd: 'Supplier',
                                                                          popupContext: bc,
                                                                        );
                                                                      });
                                                                }),
                                                              ),
                                                              PopupMenuItem(
                                                                value: 'delete',
                                                                child: Row(
                                                                  children: [
                                                                    const Icon(Icons.delete_outline, size: 18.0, color: kTitleColor),
                                                                    const SizedBox(width: 4.0),
                                                                    Text(
                                                                      lang.S.of(context).delete,
                                                                      style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                    ),
                                                                  ],
                                                                ).onTap(() {
                                                                  if (!isDemo) {
                                                                    if (double.parse(showAbleSuppliers[index].dueAmount.toString()) == 0) {
                                                                      showDialog(
                                                                          barrierDismissible: false,
                                                                          context: context,
                                                                          builder: (BuildContext dialogContext) {
                                                                            return Center(
                                                                              child: Container(
                                                                                decoration: const BoxDecoration(
                                                                                  color: Colors.white,
                                                                                  borderRadius: BorderRadius.all(
                                                                                    Radius.circular(15),
                                                                                  ),
                                                                                ),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(20.0),
                                                                                  child: Column(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        lang.S.of(context).areYouWantToDeleteThisCustomer,
                                                                                        style: const TextStyle(fontSize: 22),
                                                                                      ),
                                                                                      const SizedBox(height: 30),
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        children: [
                                                                                          GestureDetector(
                                                                                            child: Container(
                                                                                              width: 130,
                                                                                              height: 50,
                                                                                              decoration: const BoxDecoration(
                                                                                                color: Colors.green,
                                                                                                borderRadius: BorderRadius.all(
                                                                                                  Radius.circular(15),
                                                                                                ),
                                                                                              ),
                                                                                              child: Center(
                                                                                                child: Text(
                                                                                                  lang.S.of(context).cancel,
                                                                                                  style: const TextStyle(color: Colors.white),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            onTap: () {
                                                                                              Navigator.pop(dialogContext);
                                                                                              Navigator.pop(bc);
                                                                                            },
                                                                                          ),
                                                                                          const SizedBox(width: 30),
                                                                                          GestureDetector(
                                                                                            child: Container(
                                                                                              width: 130,
                                                                                              height: 50,
                                                                                              decoration: const BoxDecoration(
                                                                                                color: Colors.red,
                                                                                                borderRadius: BorderRadius.all(
                                                                                                  Radius.circular(15),
                                                                                                ),
                                                                                              ),
                                                                                              child: Center(
                                                                                                child: Text(
                                                                                                  lang.S.of(context).delete,
                                                                                                  style: const TextStyle(color: Colors.white),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            onTap: () {
                                                                                              deleteCustomer(
                                                                                                  phoneNumber: showAbleSuppliers[index].phoneNumber, updateRef: ref, context: bc);
                                                                                              Navigator.pop(dialogContext);
                                                                                            },
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          });
                                                                    } else {
                                                                      EasyLoading.showError('Este Fornecedor tem dividas anteriores');
                                                                      Navigator.pop(bc);
                                                                    }
                                                                  } else {
                                                                    EasyLoading.showInfo(demoText);
                                                                  }
                                                                }),
                                                              )
                                                            ],
                                                            onSelected: (value) {
                                                              Navigator.pushNamed(context, '$value');
                                                            },
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
                                              ),
                                            ),
                                          )
                                        : EmptyWidget(title: lang.S.of(context).noSupplierFound),
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
