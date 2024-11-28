// ignore_for_file: use_build_context_synchronously, unused_result

import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/Product/add_product.dart';
import 'package:salespro_admin/Screen/Product/product%20barcode/barcode_generate.dart';
import 'package:salespro_admin/Screen/tax%20rates/tax_model.dart';
import 'package:salespro_admin/commas.dart';
import 'package:salespro_admin/currency.dart';
import 'package:salespro_admin/model/product_model.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../Provider/product_provider.dart';
import '../../const.dart';
import '../../subscription.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Constant Data/export_button.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';
import 'WarebasedProduct.dart';
import 'bulk.dart';
import 'edit_product.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  static const String route = '/product';

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  int selectedItem = 10;
  int itemCount = 10;
  String searchItem = '';
  bool isRegularSelected = true;

  List<String> title = ['Lista de Produtos', 'Produtos a Expirar'];

  String isSelected = 'Lista de Produtos';

  void productStockEditPopUp({required ProductModel product, required BuildContext popUp, required WidgetRef pref}) {
    final ref = FirebaseDatabase.instance.ref(constUserId).child('Products');
    String productKey = '';
    ref.keepSynced(true);

    ref.orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['productCode'].toString() == product.productCode) {
          productKey = element.key.toString();
        }
      }
    });

    TextEditingController stockController = TextEditingController(text: '0');
    TextEditingController saleController = TextEditingController(text: myFormat.format(double.tryParse(product.productSalePrice) ?? 0));
    TextEditingController purchaseController = TextEditingController(text: myFormat.format(double.tryParse(product.productPurchasePrice) ?? 0));
    TextEditingController wholeSeller = TextEditingController(text: myFormat.format(double.tryParse(product.productWholeSalePrice) ?? 0));
    TextEditingController dealer = TextEditingController(text: myFormat.format(double.tryParse(product.productDealerPrice) ?? 0));

    String stock = '0';
    String productSalePrice = product.productSalePrice;
    String productPurchasePrice = product.productPurchasePrice;
    String productWholePrice = product.productWholeSalePrice;
    String productDealerPrice = product.productDealerPrice;

    GlobalKey<FormState> priceKey = GlobalKey<FormState>();
    bool validateAndSave() {
      final form = priceKey.currentState;
      if (form!.validate()) {
        form.save();
        return true;
      }
      return false;
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context1, setState1) {
            return Dialog(
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: SizedBox(
                width: 500,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
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
                                "${product.productName} (${product.productStock})",
                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 20.0),
                              ),
                              const Spacer(),
                              const Icon(FeatherIcons.x, color: kTitleColor, size: 25.0).onTap(() => {finish(context)})
                            ],
                          ),
                        ),
                        const Divider(thickness: 1.0, color: kLitGreyColor),
                        const SizedBox(height: 10.0),
                        Form(
                          key: priceKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: stockController,
                                onChanged: (value) {
                                  stock = value.replaceAll(',', '');
                                  var formattedText = myFormat.format(num.parse(stock));
                                  stockController.value = stockController.value.copyWith(
                                    text: formattedText,
                                    selection: TextSelection.collapsed(offset: formattedText.length),
                                  );
                                },
                                validator: (value) {
                                  if (stock.isEmptyOrNull) {
                                    return 'Por favor insira o estoque';
                                  } else if (double.tryParse(stock) == null && stock.isEmptyOrNull) {
                                    return 'Insira o estoque em número.';
                                  } else {
                                    return null;
                                  }
                                },
                                showCursor: true,
                                cursorColor: kTitleColor,
                                decoration: kInputDecoration.copyWith(
                                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                                  labelText: lang.S.of(context).productStock,
                                  hintText: lang.S.of(context).pleaseEnterProductStock,
                                  hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                  labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: purchaseController,
                                      onChanged: (value) {
                                        productPurchasePrice = value.replaceAll(',', '');
                                        var formattedText = myFormat.format(num.parse(productPurchasePrice));
                                        purchaseController.value = purchaseController.value.copyWith(
                                          text: formattedText,
                                          selection: TextSelection.collapsed(offset: formattedText.length),
                                        );
                                      },
                                      validator: (value) {
                                        if (productPurchasePrice.isEmptyOrNull) {
                                          return 'Por favor insira o preço de compra';
                                        } else if (double.tryParse(productPurchasePrice) == null && productPurchasePrice.isEmptyOrNull) {
                                          return 'Insira o preço de compra em número.';
                                        } else {
                                          return null;
                                        }
                                      },
                                      showCursor: true,
                                      cursorColor: kTitleColor,
                                      decoration: kInputDecoration.copyWith(
                                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                                        labelText: lang.S.of(context).purchasePrice,
                                        hintText: lang.S.of(context).enterPurchasePrice,
                                        hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                        labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: TextFormField(
                                      controller: saleController,
                                      onChanged: (value) {
                                        productSalePrice = value.replaceAll(',', '');
                                        var formattedText = myFormat.format(num.parse(productSalePrice));
                                        saleController.value = saleController.value.copyWith(
                                          text: formattedText,
                                          selection: TextSelection.collapsed(offset: formattedText.length),
                                        );
                                      },
                                      validator: (value) {
                                        if (productSalePrice.isEmptyOrNull) {
                                          return 'Insira o preço de venda';
                                        } else if (double.tryParse(productSalePrice) == null && productSalePrice.isEmptyOrNull) {
                                          return 'Insira o preço em número.';
                                        } else {
                                          return null;
                                        }
                                      },
                                      showCursor: true,
                                      cursorColor: kTitleColor,
                                      decoration: kInputDecoration.copyWith(
                                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                                        labelText: lang.S.of(context).salePrices,
                                        hintText: lang.S.of(context).enterSalePrice,
                                        hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                        labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: dealer,
                                      onChanged: (value) {
                                        productDealerPrice = value.replaceAll(',', '');
                                        var formattedText = myFormat.format(num.parse(productDealerPrice));
                                        dealer.value = dealer.value.copyWith(
                                          text: formattedText,
                                          selection: TextSelection.collapsed(offset: formattedText.length),
                                        );
                                      },
                                      validator: (value) {
                                        return null;
                                      },
                                      showCursor: true,
                                      cursorColor: kTitleColor,
                                      decoration: kInputDecoration.copyWith(
                                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                                        labelText: lang.S.of(context).dealerPrice,
                                        hintText: lang.S.of(context).enterDealePrice,
                                        hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                        labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: TextFormField(
                                      controller: wholeSeller,
                                      onChanged: (value) {
                                        productWholePrice = value.replaceAll(',', '');
                                        var formattedText = myFormat.format(num.parse(productWholePrice));
                                        wholeSeller.value = wholeSeller.value.copyWith(
                                          text: formattedText,
                                          selection: TextSelection.collapsed(offset: formattedText.length),
                                        );
                                      },
                                      validator: (value) {
                                        return null;
                                      },
                                      showCursor: true,
                                      cursorColor: kTitleColor,
                                      decoration: kInputDecoration.copyWith(
                                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                                        labelText: lang.S.of(context).wholeSaleprice,
                                        hintText: lang.S.of(context).enterPrice,
                                        hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                        labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
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
                                )).onTap(() {
                              Navigator.pop(context);
                            }),
                            const SizedBox(width: 10.0),
                            GestureDetector(
                              onTap: () {
                                if (validateAndSave()) {
                                  DatabaseReference ref = FirebaseDatabase.instance.ref("$constUserId/Products/$productKey");
                                  ref.keepSynced(true);
                                  ref.update({
                                    'productStock': ((num.tryParse(stock) ?? 0) + (num.tryParse(product.productStock) ?? 0)).toString(),
                                    // 'productStock': stockController.text,
                                    'productSalePrice': productSalePrice,
                                    'productPurchasePrice': productPurchasePrice,
                                    'productWholeSalePrice': productWholePrice,
                                    'productDealerPrice': productDealerPrice,
                                  });
                                  EasyLoading.showSuccess('Done');
                                  pref.refresh(productProvider);
                                  Navigator.pop(context);
                                  Navigator.pop(popUp);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0, bottom: 10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: kBlueTextColor,
                                ),
                                child: Text(
                                  lang.S.of(context).submit,
                                  style: kTextStyle.copyWith(color: kWhite),
                                ),
                              ),
                            )
                          ],
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

  void deleteProduct({required String productCode, required WidgetRef updateProduct, required BuildContext context}) async {
    EasyLoading.show(status: 'Apagando..');
    String customerKey = '';
    await FirebaseDatabase.instance.ref(await getUserID()).child('Products').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['productCode'].toString() == productCode) {
          customerKey = element.key.toString();
        }
      }
    });
    DatabaseReference ref = FirebaseDatabase.instance.ref("${await getUserID()}/Products/$customerKey");
    await ref.remove();
    updateProduct.refresh(productProvider);
    Navigator.pop(context);
    EasyLoading.showSuccess('Done');
  }

  ScrollController mainScroll = ScrollController();

  int _productsPerPage = 10; // Default number of items to display
  int _currentPage = 1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkCurrentUserAndRestartApp();
  }

  @override
  Widget build(BuildContext context) {
    print('Build Called');
    List<String> allProductsNameList = [];
    List<String> allProductsCodeList = [];
    List<WarehouseBasedProductModel> warehouseBasedProductModel = [];
    return Scaffold(
      backgroundColor: kDarkWhite,
      body: Scrollbar(
        controller: mainScroll,
        child: SingleChildScrollView(
          controller: mainScroll,
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, watch) {
              AsyncValue<List<ProductModel>> productList = ref.watch(productProvider);
              final groupTax = ref.watch(groupTaxProvider);
              return productList.when(data: (allProducts) {
                List<ProductModel> showAbleProducts = [];
                for (var element in allProducts) {
                  allProductsNameList.add(element.productName.removeAllWhiteSpace().toLowerCase());
                  allProductsCodeList.add(element.productCode.removeAllWhiteSpace().toLowerCase());
                  warehouseBasedProductModel.add(WarehouseBasedProductModel(element.productName, element.warehouseId));
                  if (!isRegularSelected) {
                    if (((element.productName.removeAllWhiteSpace().toLowerCase().contains(searchItem.toLowerCase()) || element.productName.contains(searchItem))) &&
                        element.expiringDate != null &&
                        ((DateTime.tryParse(element.expiringDate ?? '') ?? DateTime.now()).isBefore(DateTime.now().add(const Duration(days: 7))))) {
                      showAbleProducts.add(element);
                    }
                  } else {
                    if (searchItem != '' &&
                        (element.productName.removeAllWhiteSpace().toLowerCase().contains(searchItem.toLowerCase()) || element.productName.contains(searchItem))) {
                      showAbleProducts.add(element);
                    } else if (searchItem == '') {
                      showAbleProducts.add(element);
                    }
                  }
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 240,
                      child: SideBarWidget(
                        index: 3,
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
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: kWhite),
                                    child: Column(
                                      children: [
                                        ///________title and add product_______________________________________
                                        Row(
                                          children: [
                                            // Text(
                                            //   lang.S.of(context).productList,
                                            //   style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                            // ),
                                            // const SizedBox(width: 10.0),
                                            Container(
                                              padding: const EdgeInsets.fromLTRB(8.0, 4, 8.0, 4.0),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8.0),
                                                border: Border.all(color: Colors.grey),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text('Result-'),
                                                  DropdownButton<int>(
                                                    isDense: true,
                                                    padding: EdgeInsets.zero,
                                                    underline: const SizedBox(),
                                                    value: _productsPerPage,
                                                    icon: const Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: Colors.black,
                                                    ),
                                                    items: [10, 20, 50, 100, -1].map<DropdownMenuItem<int>>((int value) {
                                                      return DropdownMenuItem<int>(
                                                        value: value,
                                                        child: Text(
                                                          value == -1 ? "All" : value.toString(),
                                                          style: const TextStyle(color: Colors.black),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (int? newValue) {
                                                      setState(() {
                                                        if (newValue == -1) {
                                                          _productsPerPage = -1; // Set to -1 for "All"
                                                        } else {
                                                          _productsPerPage = newValue ?? 10;
                                                        }
                                                        _currentPage = 1;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 20),

                                            ///___________search________________________________________________-
                                            Container(
                                              height: 40.0,
                                              width: MediaQuery.of(context).size.width * .20,
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
                                                  hintText: (lang.S.of(context).searchByName),
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
                                            const Spacer(),
                                            SizedBox(
                                              height: 42,
                                              child: ListView.builder(
                                                  itemCount: 2,
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.zero,
                                                  scrollDirection: Axis.horizontal,
                                                  itemBuilder: (_, index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          // isRegularSelected = index == 0;
                                                          _currentPage = 1;
                                                          isSelected = title[index];
                                                          isRegularSelected = index == 0;
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 10.0),
                                                        child: Container(
                                                          padding: const EdgeInsets.all(10.0),
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(5.0),
                                                              color: isSelected == title[index] ? kBlueTextColor : white,
                                                              border: Border.all(
                                                                color: isSelected == title[index] ? kBlueTextColor : kBorderColorTextField,
                                                              )),
                                                          child: Text(
                                                            title[index],
                                                            style: kTextStyle.copyWith(
                                                              color: isSelected == title[index] ? kWhite : kTitleColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),

                                            // SizedBox(
                                            //   height: 42,
                                            //   child: ToggleButtons(
                                            //     isSelected: [isRegularSelected, !isRegularSelected],
                                            //     onPressed: (index) {
                                            //       setState(() {
                                            //         isRegularSelected = index == 0;
                                            //       });
                                            //     },
                                            //     color: Colors.black,
                                            //     selectedColor: Colors.white,
                                            //     fillColor: kBlueTextColor,
                                            //     borderRadius: BorderRadius.circular(5),
                                            //     children: [
                                            //       Container(
                                            //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            //         child: Text(lang.S.of(context).productList),
                                            //       ),
                                            //
                                            //       Container(
                                            //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            //         child: const Text('Expired List'),
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ),
                                            const SizedBox(width: 10),

                                            Container(
                                              padding: const EdgeInsets.all(10.0),
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: kWhite, border: Border.all(color: kBorderColorTextField)),
                                              child: Text(
                                                "Upload em massa",
                                                style: kTextStyle.copyWith(color: kTitleColor),
                                              ),
                                            ).onTap(() async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) => BulkProductUploadPopup(allProductsCodeList: allProductsCodeList, allProductsNameList: allProductsNameList),
                                              );
                                              setState(() {});

                                              // if (await Subscription.subscriptionChecker(item: Product.route)) {
                                              //   AddProduct(
                                              //     allProductsCodeList: allProductsCodeList,
                                              //     allProductsNameList: allProductsNameList,
                                              //     sideBarNumber: 3,
                                              //   ).launch(context);
                                              // } else {
                                              //   EasyLoading.showError(lang.S.of(context).updateYourPlanFirst);
                                              // }
                                            }),
                                            const SizedBox(width: 10),

                                            ///________________add_productS________________________________________________
                                            Container(
                                              padding: const EdgeInsets.all(10.0),
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: kWhite, border: Border.all(color: kBorderColorTextField)),
                                              child: Row(
                                                children: [
                                                  const Icon(FeatherIcons.plus, color: kTitleColor, size: 18.0),
                                                  const SizedBox(width: 5.0),
                                                  Text(
                                                    lang.S.of(context).addProduct,
                                                    style: kTextStyle.copyWith(color: kTitleColor),
                                                  ),
                                                ],
                                              ),
                                            ).onTap(() async {
                                              if (await Subscription.subscriptionChecker(item: 'Products')) {
                                                AddProduct(
                                                  allProductsCodeList: allProductsCodeList,
                                                  warehouseBasedProductModel: [],
                                                  sideBarNumber: 3,
                                                ).launch(context);
                                              } else {
                                                EasyLoading.showError(lang.S.of(context).updateYourPlanFirst);
                                              }
                                            }),
                                            const SizedBox(width: 10),

                                            ///________________add_productS________________________________________________
                                            InkWell(
                                              onTap: () => Navigator.pushNamed(context, BarcodeGenerate.route),
                                              child: Container(
                                                padding: const EdgeInsets.all(10.0),
                                                decoration:
                                                    BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: kWhite, border: Border.all(color: kBorderColorTextField)),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.qr_code, color: kTitleColor, size: 18.0),
                                                    const SizedBox(width: 5.0),
                                                    Text(
                                                      'Gerar Códigos',
                                                      style: kTextStyle.copyWith(color: kTitleColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 5.0),
                                        Divider(
                                          thickness: 1.0,
                                          color: kGreyTextColor.withOpacity(0.2),
                                        ),

                                        ///_______product_list______________________________________________________
                                        const SizedBox(height: 20.0),

                                        showAbleProducts.isNotEmpty
                                            ? Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: (MediaQuery.of(context).size.height - 315).isNegative ? 0 : MediaQuery.of(context).size.height - 315,
                                                    width: MediaQuery.of(context).size.width < 1275 ? 1275 - 240 : MediaQuery.of(context).size.width - 240,
                                                    child: SingleChildScrollView(
                                                      child: DataTable(
                                                        border: const TableBorder(
                                                          horizontalInside: BorderSide(
                                                            width: 1,
                                                            color: kBorderColorTextField,
                                                          ),
                                                        ),
                                                        showCheckboxColumn: true,
                                                        dividerThickness: 1.0,
                                                        dataRowColor: const MaterialStatePropertyAll(Colors.white),
                                                        headingRowColor: MaterialStateProperty.all(kbgColor),
                                                        showBottomBorder: true,
                                                        headingTextStyle: const TextStyle(
                                                          color: Colors.black,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        dataTextStyle: const TextStyle(color: Colors.black),
                                                        columns: [
                                                          const DataColumn(
                                                            label: Text('Nr'),
                                                          ),
                                                          const DataColumn(label: Text('Image')),
                                                          DataColumn(
                                                              label: Flexible(
                                                                  child: Text(
                                                            'Nome do produto',
                                                            style: kTextStyle.copyWith(color: Colors.black, overflow: TextOverflow.ellipsis),
                                                          ))),
                                                          const DataColumn(label: Text('Categoria')),
                                                          const DataColumn(label: Text('Cliente')),
                                                          const DataColumn(label: Text('Distribuidora')),
                                                          const DataColumn(label: Text('Atacado')),
                                                          const DataColumn(label: Text('Armazém')),
                                                          const DataColumn(label: Text('Estoque')),
                                                          const DataColumn(label: Icon(Icons.settings)),
                                                        ],
                                                        rows: List.generate(
                                                          _productsPerPage == -1
                                                              ? showAbleProducts.length
                                                              : (_currentPage - 1) * _productsPerPage + _productsPerPage <= showAbleProducts.length
                                                                  ? _productsPerPage
                                                                  : showAbleProducts.length - (_currentPage - 1) * _productsPerPage,
                                                          (index) {
                                                            final dataIndex = (_currentPage - 1) * _productsPerPage + index;
                                                            final product = showAbleProducts[dataIndex];
                                                            return DataRow(
                                                              cells: [
                                                                DataCell(
                                                                  Text('${(_currentPage - 1) * _productsPerPage + index + 1}'),
                                                                ),
                                                                DataCell(
                                                                  Container(
                                                                    height: 40,
                                                                    width: 40,
                                                                    decoration: BoxDecoration(
                                                                      shape: BoxShape.circle,
                                                                      border: Border.all(color: kBorderColorTextField),
                                                                      image: DecorationImage(
                                                                          image: NetworkImage(
                                                                            product.productPicture,
                                                                          ),
                                                                          fit: BoxFit.cover),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  Text(
                                                                    product.productName,
                                                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  Text(
                                                                    (!isRegularSelected && product.expiringDate != null)
                                                                        ? ((DateTime.tryParse(product.expiringDate ?? '') ?? DateTime.now())
                                                                                .isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
                                                                            ? 'Expirado'
                                                                            : "Expirará em\n${DateFormat.yMMMd().format(DateTime.tryParse(product.expiringDate ?? '') ?? DateTime.now())}")
                                                                        : product.productCategory,
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: kTextStyle.copyWith(
                                                                        color: (!isRegularSelected && product.expiringDate != null) ? Colors.red : kGreyTextColor),
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  Text(
                                                                    "$currency ${myFormat.format(double.tryParse(product.productSalePrice) ?? 0)}",
                                                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  Text(
                                                                    "${myFormat.format(double.tryParse(product.productDealerPrice) ?? 0)} $currency",
                                                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  Text(
                                                                    "${myFormat.format(double.tryParse(product.productWholeSalePrice) ?? 0)} $currency",
                                                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  Text(
                                                                    product.warehouseName,
                                                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  Text(
                                                                    myFormat.format(double.tryParse(product.productStock) ?? 0),
                                                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  StatefulBuilder(
                                                                    builder: (BuildContext context, void Function(void Function()) setState) {
                                                                      return Theme(
                                                                        data: ThemeData(
                                                                            highlightColor: dropdownItemColor, focusColor: dropdownItemColor, hoverColor: dropdownItemColor),
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
                                                                              ).onTap(
                                                                                () => EditProduct(
                                                                                  productModel: product,
                                                                                  allProductsNameList: allProductsNameList,
                                                                                  groupTaxModel: groupTax.value ?? [],
                                                                                ).launch(context),
                                                                              ),
                                                                            ),
                                                                            PopupMenuItem(
                                                                                child: Row(
                                                                              children: [
                                                                                const Icon(Icons.add, size: 18.0, color: kTitleColor),
                                                                                const SizedBox(width: 4.0),
                                                                                Text(
                                                                                  lang.S.of(context).increaseStock,
                                                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                                ),
                                                                              ],
                                                                            ).onTap(
                                                                              () {
                                                                                productStockEditPopUp(product: product, popUp: bc, pref: ref);
                                                                              },
                                                                            )),
                                                                            PopupMenuItem(
                                                                              child: GestureDetector(
                                                                                onTap: () {
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
                                                                                                    lang.S.of(context).areYouWantToDeleteThisProduct,
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
                                                                                                            deleteProduct(
                                                                                                              productCode: product.productCode,
                                                                                                              updateProduct: ref,
                                                                                                              context: bc,
                                                                                                            );
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
                                                                                },
                                                                                child: Row(
                                                                                  children: [
                                                                                    const Icon(
                                                                                      Icons.delete_outline,
                                                                                      size: 18,
                                                                                      color: kTitleColor,
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 5,
                                                                                    ),
                                                                                    Text(
                                                                                      lang.S.of(context).delete,
                                                                                      style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
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
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'showing ${((_currentPage - 1) * _productsPerPage + 1).toString()} to ${((_currentPage - 1) * _productsPerPage + _productsPerPage).clamp(0, showAbleProducts.length)} of ${showAbleProducts.length} entries',
                                                        ),
                                                        const Spacer(),
                                                        Row(
                                                          children: [
                                                            InkWell(
                                                              overlayColor: MaterialStateProperty.all<Color>(Colors.grey),
                                                              hoverColor: Colors.grey,
                                                              onTap: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                                                              child: Container(
                                                                height: 32,
                                                                width: 90,
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(color: kBorderColorTextField),
                                                                  borderRadius: const BorderRadius.only(
                                                                    bottomLeft: Radius.circular(4.0),
                                                                    topLeft: Radius.circular(4.0),
                                                                  ),
                                                                ),
                                                                child: const Center(
                                                                  child: Text('Anterior'),
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              height: 32,
                                                              width: 32,
                                                              decoration: BoxDecoration(
                                                                border: Border.all(color: kMainColor),
                                                                color: kMainColor,
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  '$_currentPage',
                                                                  style: const TextStyle(color: Colors.white),
                                                                ),
                                                              ),
                                                            ),
                                                            InkWell(
                                                              hoverColor: Colors.blue.withOpacity(0.1),
                                                              overlayColor: MaterialStateProperty.all<Color>(Colors.blue),
                                                              onTap: _currentPage * _productsPerPage < showAbleProducts.length ? () => setState(() => _currentPage++) : null,
                                                              child: Container(
                                                                height: 32,
                                                                width: 90,
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(color: kBorderColorTextField),
                                                                  borderRadius: const BorderRadius.only(
                                                                    bottomRight: Radius.circular(4.0),
                                                                    topRight: Radius.circular(4.0),
                                                                  ),
                                                                ),
                                                                child: const Center(child: Text('Próximo')),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : EmptyWidget(title: lang.S.of(context).noProductFound),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
            },
          ),
        ),
      ),
    );
  }
}
