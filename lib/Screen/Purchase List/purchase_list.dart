import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Provider/customer_provider.dart';
import 'package:salespro_admin/Screen/Purchase%20List/purchase_edit.dart';
import 'package:salespro_admin/Screen/Purchase%20Return/purchase_return_screen.dart';
import 'package:salespro_admin/commas.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../PDF/print_pdf.dart';
import '../../Provider/daily_transaction_provider.dart';
import '../../Provider/product_provider.dart';
import '../../Provider/profile_provider.dart';
import '../../Provider/transactions_provider.dart';
import '../../const.dart';
import '../../delete_invoice_functions.dart';
import '../../model/purchase_transation_model.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Constant Data/export_button.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';

class PurchaseList extends StatefulWidget {
  const PurchaseList({super.key});

  static const String route = '/purchaseList';

  @override
  State<PurchaseList> createState() => _PurchaseListState();
}

class _PurchaseListState extends State<PurchaseList> {
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
              final purchaseList = consuearRef.watch(purchaseTransitionProvider);
              final profile = consuearRef.watch(profileDetailsProvider);
              return purchaseList.when(data: (purchase) {
                final allTransaction = purchase.reversed.toList();

                List<PurchaseTransactionModel> showAblePurchaseTransactions = [];
                for (var element in allTransaction) {
                  if (searchItem != '' &&
                      (element.invoiceNumber.toLowerCase().contains(searchItem.toLowerCase()) || element.customerName.toLowerCase().contains(searchItem.toLowerCase()))) {
                    showAblePurchaseTransactions.add(element);
                  } else if (searchItem == '') {
                    showAblePurchaseTransactions.add(element);
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
                        subManu: 'Purchase List',
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
                                          lang.S.of(context).purchaseList,
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
                                              hintText: (lang.S.of(context).searchByInvoice),
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
                                    showAblePurchaseTransactions.isNotEmpty
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
                                                  itemCount: showAblePurchaseTransactions.length,
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
                                                                  showAblePurchaseTransactions[index].purchaseDate.substring(0, 10),
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 2,
                                                                  style: kTextStyle.copyWith(color: kGreyTextColor, overflow: TextOverflow.ellipsis),
                                                                ),
                                                              ),

                                                              ///____________Invoice_________________________________________________
                                                              SizedBox(
                                                                width: 50,
                                                                child: Text(showAblePurchaseTransactions[index].invoiceNumber,
                                                                    maxLines: 2, overflow: TextOverflow.ellipsis, style: kTextStyle.copyWith(color: kGreyTextColor)),
                                                              ),

                                                              ///______Party Name___________________________________________________________
                                                              SizedBox(
                                                                width: 180,
                                                                child: Text(
                                                                  showAblePurchaseTransactions[index].customerName,
                                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),

                                                              ///___________Party Type______________________________________________

                                                              SizedBox(
                                                                width: 100,
                                                                child: Text(
                                                                  showAblePurchaseTransactions[index].paymentType.toString(),
                                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),

                                                              ///___________Amount____________________________________________________
                                                              SizedBox(
                                                                width: 70,
                                                                child: Text(
                                                                  myFormat.format(double.tryParse(showAblePurchaseTransactions[index].totalAmount.toString()) ?? 0),
                                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),

                                                              ///___________Due____________________________________________________

                                                              SizedBox(
                                                                width: 70,
                                                                child: Text(
                                                                  myFormat.format(double.tryParse(showAblePurchaseTransactions[index].dueAmount.toString()) ?? 0),
                                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),

                                                              ///___________Due____________________________________________________

                                                              SizedBox(
                                                                width: 50,
                                                                child: Text(
                                                                  showAblePurchaseTransactions[index].isPaid! ? 'Pago' : "Devendo",
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
                                                                            await GeneratePdfAndPrint().printPurchaseInvoice(
                                                                                personalInformationModel: profile.value!,
                                                                                purchaseTransactionModel: showAblePurchaseTransactions[index]);
                                                                            // PurchaseInvoice(
                                                                            //   isPurchase: false,
                                                                            //   personalInformationModel: profile.value!,
                                                                            //   transitionModel: showAblePurchaseTransactions[index],
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

                                                                      ///________Edit_Purchase_______________________________
                                                                      PopupMenuItem(
                                                                        child: GestureDetector(
                                                                          onTap: () {
                                                                            PurchaseEdit(
                                                                              personalInformationModel: profile.value!,
                                                                              isPosScreen: false,
                                                                              purchaseTransitionModel: showAblePurchaseTransactions[index],
                                                                              popupContext: bc,
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

                                                                      ///________Purchase Delete_______________________________
                                                                      PopupMenuItem(
                                                                        child: GestureDetector(
                                                                          onTap: () => showDialog(
                                                                              context: context,
                                                                              builder: (context2) => AlertDialog(
                                                                                    title: const Text('Tem certeza de que deseja excluir esta compra?'),
                                                                                    content: const Text(
                                                                                      'A venda será excluída e todos os dados sobre esta compra serão excluídos. Tem certeza de excluir esta?',
                                                                                      maxLines: 5,
                                                                                    ),
                                                                                    actions: [
                                                                                      const Text('Cancelar').onTap(() => Navigator.pop(context2)),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.all(20.0),
                                                                                        child: const Text('Sim, excluir para sempre').onTap(() async {
                                                                                          EasyLoading.show();

                                                                                          DeleteInvoice delete = DeleteInvoice();

                                                                                          await delete.editStockAndSerialForPurchase(
                                                                                              saleTransactionModel: showAblePurchaseTransactions[index]);

                                                                                          await delete.customerDueUpdate(
                                                                                            due: showAblePurchaseTransactions[index].dueAmount ?? 0,
                                                                                            phone: showAblePurchaseTransactions[index].customerPhone,
                                                                                          );
                                                                                          await delete.updateFromShopRemainBalance(
                                                                                            paidAmount: (showAblePurchaseTransactions[index].totalAmount ?? 0) -
                                                                                                (showAblePurchaseTransactions[index].dueAmount ?? 0),
                                                                                            isFromPurchase: true,
                                                                                          );
                                                                                          await delete.deleteDailyTransaction(
                                                                                              invoice: showAblePurchaseTransactions[index].invoiceNumber,
                                                                                              status: 'Purchase',
                                                                                              field: 'purchaseTransactionModel');
                                                                                          DatabaseReference ref = FirebaseDatabase.instance.ref(
                                                                                              "${await getUserID()}/Purchase Transition/${showAblePurchaseTransactions[index].key}");

                                                                                          await ref.remove();
                                                                                          consuearRef.refresh(purchaseTransitionProvider);
                                                                                          consuearRef.refresh(productProvider);
                                                                                          consuearRef.refresh(supplierProvider);
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
                                                                                  builder: (context) => PurchaseReturnScreen(
                                                                                    purchaseTransactionModel: showAblePurchaseTransactions[index],
                                                                                  ),
                                                                                ));
                                                                          },
                                                                          child: Row(
                                                                            children: [
                                                                              const Icon(Icons.assignment_return, size: 18.0, color: kTitleColor),
                                                                              const SizedBox(width: 4.0),
                                                                              Text(
                                                                                'Fazer Devolução',
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
                                        : EmptyWidget(title: lang.S.of(context).noPurchaseTransactionFound)
                                  ],
                                ),
                              ),
                            ),
                            const Footer(),
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
