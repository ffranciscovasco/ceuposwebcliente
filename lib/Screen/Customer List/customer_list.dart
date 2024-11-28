// ignore_for_file: unused_result, use_build_context_synchronously

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:restart_app/restart_app.dart';
import 'package:salespro_admin/Screen/Customer%20List/edit_customer.dart';
import 'package:salespro_admin/Screen/Supplier%20List/supplier_list.dart';
import 'package:salespro_admin/commas.dart';
import 'package:salespro_admin/model/customer_model.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../Provider/customer_provider.dart';
import '../../Provider/product_provider.dart';
import '../../const.dart';
import '../../subscription.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Constant Data/export_button.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';
import 'add_customer.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({Key? key}) : super(key: key);

  static const String route = '/customerList';

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  int selectedItem = 10;
  int itemCount = 10;

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
    Navigator.pop(context);
    EasyLoading.showSuccess('Done');
  }

  ScrollController mainScroll = ScrollController();
  String searchItem = '';

  @override
  void initState() {
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
                return customers.when(data: (list) {
                  List<CustomerModel> allCustomerList = list.reversed.toList();
                  List<String> listOfPhoneNumber = [];
                  List<CustomerModel> customerLists = [];
                  List<CustomerModel> showAbleCustomer = [];
                  for (var value1 in allCustomerList) {
                    listOfPhoneNumber.add(value1.phoneNumber.removeAllWhiteSpace().toLowerCase());
                    if (value1.type != 'Supplier') {
                      customerLists.add(value1);
                    }
                  }
                  for (var element in customerLists) {
                    if (element.customerName.removeAllWhiteSpace().toLowerCase().contains(searchItem.toLowerCase()) || element.phoneNumber.contains(searchItem)) {
                      showAbleCustomer.add(element);
                    } else if (searchItem == '') {
                      showAbleCustomer.add(element);
                    }
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 240,
                        child: SideBarWidget(
                          index: 6,
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
                                            lang.S.of(context).customerList,
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
                                                  lang.S.of(context).addCustomer,
                                                  style: kTextStyle.copyWith(color: kWhite),
                                                ),
                                              ],
                                            ),
                                          ).onTap(() async {
                                            if (await Subscription.subscriptionChecker(item: "Parties")) {
                                              showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AddCustomer(
                                                      typeOfCustomerAdd: 'Buyer',
                                                      listOfPhoneNumber: listOfPhoneNumber,
                                                      sideBarNumber: 6,
                                                    );
                                                  });
                                            }
                                            // else {
                                            //   EasyLoading.showError('Update your plan first\nAdd Customer limit is over.');
                                            // }
                                          })
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      Divider(
                                        thickness: 1.0,
                                        color: kGreyTextColor.withOpacity(0.2),
                                      ),

                                      ///__________Customer_List________________________________________________

                                      const SizedBox(height: 20.0),
                                      showAbleCustomer.isNotEmpty
                                          ? Column(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(15),
                                                  decoration: const BoxDecoration(color: kbgColor),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      const SizedBox(width: 50, child: Text('Nr')),
                                                      SizedBox(width: 230, child: Text(lang.S.of(context).partyName)),
                                                     /// SizedBox(width: 75, child: Text(lang.S.of(context).partyType)),
                                                      SizedBox(width: 100, child: Text(lang.S.of(context).phone)),
                                                      SizedBox(width: 150, child: Text(lang.S.of(context).email)),
                                                      SizedBox(width: 70, child: Text(lang.S.of(context).due)),
                                                      const SizedBox(width: 30, child: Icon(FeatherIcons.settings)),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: (MediaQuery.of(context).size.height - 315).isNegative ? 0 : MediaQuery.of(context).size.height - 315,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics: const AlwaysScrollableScrollPhysics(),
                                                    itemCount: showAbleCustomer.length,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      return Padding(
                                                        padding: const EdgeInsets.only(bottom: 5),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.all(15.0),
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
                                                                    width: 230,
                                                                    child: Text(
                                                                      showAbleCustomer[index].customerName,
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
                                                                      showAbleCustomer[index].phoneNumber,
                                                                      style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                      maxLines: 2,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),

                                                                  ///___________Email____________________________________________________
                                                                  SizedBox(
                                                                    width: 150,
                                                                    child: Text(
                                                                      showAbleCustomer[index].emailAddress,
                                                                      style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                      maxLines: 2,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),

                                                                  ///___________Due____________________________________________________

                                                                  SizedBox(
                                                                    width: 70,
                                                                    child: Text(
                                                                      myFormat.format(double.tryParse(showAbleCustomer[index].dueAmount) ?? 0),
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
                                                                          ///____________Edit____________________________________________________
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
                                                                                      allPreviousCustomer: allCustomerList,
                                                                                      customerModel: showAbleCustomer[index],
                                                                                      typeOfCustomerAdd: 'Buyer',
                                                                                      popupContext: bc,
                                                                                    );
                                                                                  });
                                                                            }),
                                                                          ),

                                                                          ///____________delete___________________________________________________
                                                                          PopupMenuItem(
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
                                                                              if (double.parse(showAbleCustomer[index].dueAmount.toString()) == 0) {
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
                                                                                                        if (!isDemo) {
                                                                                                          deleteCustomer(
                                                                                                              phoneNumber: showAbleCustomer[index].phoneNumber,
                                                                                                              updateRef: ref,
                                                                                                              context: bc);
                                                                                                          Navigator.pop(dialogContext);
                                                                                                        } else {
                                                                                                          EasyLoading.showInfo(demoText);
                                                                                                        }
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
                                                                                EasyLoading.showError(lang.S.of(context).thisCustomerHavepreviousDue);
                                                                                Navigator.pop(bc);
                                                                              }
                                                                            }),
                                                                          ),
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
                                                            Container(
                                                              width: double.infinity,
                                                              height: 1,
                                                              color: kGreyTextColor.withOpacity(0.2),
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              ],
                                            )
                                          : EmptyWidget(title: lang.S.of(context).noCustomerFound)
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
