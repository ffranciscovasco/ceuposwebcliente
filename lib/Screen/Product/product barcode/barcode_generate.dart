// ignore_for_file: use_build_context_synchronously, unused_result

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:salespro_admin/currency.dart';
import 'package:salespro_admin/model/product_model.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../../PDF/print_pdf.dart';
import '../../../Provider/product_provider.dart';
import '../../../Provider/profile_provider.dart';
import '../../../Repository/product_repo.dart';
import '../../../const.dart';
import '../../../model/add_to_cart_model.dart';
import '../../../model/personal_information_model.dart';
import '../../Widgets/Constant Data/constant.dart';
import '../../Widgets/Sidebar/sidebar_widget.dart';
import '../../Widgets/TopBar/top_bar_widget.dart';
import 'barcode_pdf.dart';

class BarcodeGenerate extends StatefulWidget {
  const BarcodeGenerate({Key? key}) : super(key: key);

  static const String route = '/product/barcode';

  @override
  State<BarcodeGenerate> createState() => _BarcodeGenerateState();
}

class _BarcodeGenerateState extends State<BarcodeGenerate> {
  int selectedItem = 10;
  int itemCount = 10;
  String searchItem = '';

  TextEditingController nameCodeCategoryController = TextEditingController();
  FocusNode nameFocus = FocusNode();
  String searchProductCode = '';
  String selectedCategory = 'Categories';
  String isSelected = 'Categories';
  List<AddToCartModel> cartList = [];
  int quantity = 0;

  bool uniqueCheck(String code) {
    bool isUnique = false;
    for (var item in cartList) {
      if (item.productId == code) {
        if (item.quantity < item.stock!.toInt()) {
          item.quantity += 1;
        } else {
          EasyLoading.showError('Fora de Estoque');
        }

        isUnique = true;
        break;
      }
    }
    return isUnique;
  }

  ScrollController mainScroll = ScrollController();
  bool siteName = false;
  bool productName = false;
  bool productCode = false;
  bool price = false;

  // TextEditingController quantityController = TextEditingController();
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  PersonalInformationModel? personalInformation;

  bool generateButtonBool = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkCurrentUserAndRestartApp();
  }

  @override
  Widget build(BuildContext context) {
    List<String> allProductsNameList = [];
    List<String> allProductsCodeList = [];
    return Scaffold(
      backgroundColor: kDarkWhite,
      body: Scrollbar(
        controller: mainScroll,
        child: SingleChildScrollView(
          controller: mainScroll,
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, watch) {
              final profile = ref.watch(profileDetailsProvider);
              AsyncValue<List<ProductModel>> productList = ref.watch(productProvider);
              return productList.when(data: (product) {
                List<ProductModel> finalList = [];
                for (var element in product) {
                  allProductsNameList.add(element.productName.removeAllWhiteSpace().toLowerCase());
                  allProductsCodeList.add(element.productCode.removeAllWhiteSpace().toLowerCase());
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
                    SingleChildScrollView(
                      child: Container(
                        width: context.width() < 1080 ? 1080 - 240 : MediaQuery.of(context).size.width - 240,
                        decoration: const BoxDecoration(color: kDarkWhite),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: const BoxDecoration(
                                color: kWhite,
                              ),
                              child: const TopBar(),
                            ),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: kWhite),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ///________title and add product_______________________________________
                                        Text(
                                          'Gerador de Código de barras',
                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                        ),
                                        const SizedBox(height: 5.0),
                                        Divider(
                                          thickness: 1.0,
                                          color: kGreyTextColor.withOpacity(0.2),
                                        ),

                                        ///_______product_list______________________________________________________
                                        Center(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 20.0),
                                              productList.when(data: (product) {
                                                for (var element in product) {
                                                  allProductsNameList.add(element.productName.removeAllWhiteSpace().toLowerCase());
                                                  allProductsCodeList.add(element.productCode.removeAllWhiteSpace().toLowerCase());
                                                }
                                                return SizedBox(
                                                  width: 500,
                                                  child: TypeAheadField(
                                                    // textFieldConfiguration: TextFieldConfiguration(
                                                    //   style: DefaultTextStyle.of(context).style.copyWith(fontStyle: FontStyle.italic),
                                                    //   decoration: const InputDecoration(
                                                    //     border: OutlineInputBorder(),
                                                    //     labelText: 'Product',
                                                    //     hintText: 'Search for product',
                                                    //   ),
                                                    // ),
                                                    suggestionsCallback: (pattern) {
                                                      ProductRepo pr = ProductRepo();
                                                      return pr.getAllProductByJson(searchData: pattern);
                                                    },
                                                    itemBuilder: (context, suggestion) {
                                                      ProductModel product = ProductModel.fromJson(jsonDecode(jsonEncode(suggestion)));
                                                      return ListTile(
                                                        leading: Container(
                                                          height: 60,
                                                          width: 60,
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              border: Border.all(color: kBorderColorTextField),
                                                              image: DecorationImage(image: NetworkImage(product.productPicture), fit: BoxFit.cover)),
                                                        ),
                                                        title: Text(product.productName),
                                                        subtitle: Text('Código : ${product.productSalePrice}'),
                                                        trailing: Text('Estoque : ${product.productStock}'),
                                                      );
                                                    },
                                                    onSelected: (suggestion) {
                                                      ProductModel product = ProductModel.fromJson(jsonDecode(jsonEncode(suggestion)));
                                                      AddToCartModel addToCartModel = AddToCartModel(
                                                        productName: product.productName,
                                                        warehouseName: product.warehouseName,
                                                        warehouseId: product.warehouseId,
                                                        productId: product.productCode,
                                                        quantity: 1,
                                                        stock: product.productStock.toInt(),
                                                        productPurchasePrice: product.productSalePrice.toDouble(),
                                                        subTotal: product.productSalePrice,
                                                        productImage: product.productPicture,
                                                        subTaxes: product.subTaxes,
                                                        excTax: product.excTax,
                                                        groupTaxName: product.groupTaxName,
                                                        groupTaxRate: product.groupTaxRate,
                                                        incTax: product.incTax,
                                                        margin: product.margin,
                                                        taxType: product.taxType,
                                                      );
                                                      setState(() {
                                                        if (!uniqueCheck(product.productCode)) {
                                                          cartList.add(addToCartModel);
                                                          nameCodeCategoryController.clear();
                                                          nameFocus.requestFocus();
                                                          searchProductCode = '';
                                                        } else {
                                                          nameCodeCategoryController.clear();
                                                          nameFocus.requestFocus();
                                                          searchProductCode = '';
                                                        }
                                                      });
                                                    },
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
                                              const SizedBox(height: 20.0),
                                              Text(
                                                'Escolha os Componentes',
                                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Checkbox(
                                                    activeColor: kMainColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(2.0),
                                                    ),
                                                    value: siteName,
                                                    onChanged: (val) {
                                                      setState(
                                                        () {
                                                          siteName = val!;
                                                        },
                                                      );
                                                    },
                                                  ),
                                                  const Text('Entidade de Negócio'),
                                                  const SizedBox(width: 25.0),
                                                  Checkbox(
                                                    activeColor: kMainColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(2.0),
                                                    ),
                                                    value: productName,
                                                    onChanged: (val) {
                                                      setState(
                                                        () {
                                                          productName = val!;
                                                        },
                                                      );
                                                    },
                                                  ),
                                                  Text('Nome do Produto'),
                                                  const SizedBox(width: 25.0),
                                                  Checkbox(
                                                    activeColor: kMainColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(2.0),
                                                    ),
                                                    value: productCode,
                                                    onChanged: (val) {
                                                      setState(
                                                        () {
                                                          productCode = val!;
                                                        },
                                                      );
                                                    },
                                                  ),
                                                  Text('Codigo do Produto'),
                                                  const SizedBox(width: 25.0),
                                                  Checkbox(
                                                    activeColor: kMainColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(2.0),
                                                    ),
                                                    value: price,
                                                    onChanged: (val) {
                                                      setState(
                                                        () {
                                                          price = val!;
                                                        },
                                                      );
                                                    },
                                                  ),
                                                  Text('Preço do Produto'),
                                                ],
                                              ),
                                              const SizedBox(height: 20.0),
                                              Form(
                                                key: globalKey,
                                                child: DataTable(
                                                  border: TableBorder.all(
                                                    color: kBorderColorTextField,
                                                    borderRadius: BorderRadius.circular(5.0),
                                                  ),
                                                  dividerThickness: 1.0,
                                                  headingRowColor: MaterialStateProperty.all(kDarkWhite),
                                                  showBottomBorder: true,
                                                  headingTextStyle: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                                  dataTextStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                                  columnSpacing: 10.0,
                                                  columns: [
                                                    DataColumn(
                                                      label: Text('Produto/Código'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('Estoque'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('Qtd'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('Apgar'),
                                                    ),
                                                  ],
                                                  rows: List.generate(
                                                    cartList.length,
                                                    (index) => DataRow(
                                                      cells: [
                                                        DataCell(
                                                          Text(cartList[index].productName ?? ''),
                                                        ),
                                                        DataCell(
                                                          Text(cartList[index].stock.toString()),
                                                        ),
                                                        DataCell(
                                                          Padding(
                                                            padding: const EdgeInsets.all(5.0),
                                                            child: TextFormField(
                                                              autofocus: true,
                                                              keyboardType: TextInputType.number,
                                                              decoration: const InputDecoration(
                                                                contentPadding: EdgeInsets.only(left: 7.0, right: 7.0),
                                                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                                                border: OutlineInputBorder(),
                                                                hintText: 'quantidade a gerar',
                                                                errorStyle: TextStyle(height: 0, color: Colors.red, fontSize: 10.0),
                                                              ),
                                                              validator: (value) {
                                                                if (value == null || value.isEmpty) {
                                                                  return 'A quantidade é obrigatória';
                                                                }
                                                                int? quantity = int.tryParse(value);
                                                                if (quantity == null) {
                                                                  return 'Insira um número válido';
                                                                }
                                                                return null;
                                                              },
                                                              onChanged: (value) {
                                                                cartList[index].quantity = value.toInt();
                                                              },
                                                              onFieldSubmitted: (value) {
                                                                setState(() {
                                                                  cartList[index].quantity = value.toInt();
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          const Icon(
                                                            Icons.delete_forever,
                                                            color: redColor,
                                                          ).onTap(() {
                                                            setState(() {
                                                              cartList.removeAt(index);
                                                            });
                                                          }),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: cartList.isEmpty,
                                                child: const SizedBox(height: 10.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Center(
                                          child: Visibility(
                                            visible: cartList.isEmpty,
                                            child: Text(
                                              'No data found',
                                              style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 21.0),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20.0),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 40,
                                              width: 200,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                                                  backgroundColor: kWhite,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0), side: const BorderSide(color: kMainColor)),
                                                  textStyle: kTextStyle.copyWith(color: Colors.white),
                                                ),
                                                onPressed: () async {
                                                  if (cartList.isNotEmpty) {
                                                    setState(() {
                                                      cartList.clear();
                                                    });
                                                  }
                                                },
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.refresh, color: kMainColor),
                                                    const SizedBox(width: 5.0),
                                                    Text(
                                                      'Reiniciar',
                                                      style: kTextStyle.copyWith(color: kMainColor, fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20.0),
                                            SizedBox(
                                              height: 40,
                                              width: 200,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                                                  backgroundColor: kMainColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30.0),
                                                  ),
                                                  textStyle: kTextStyle.copyWith(color: Colors.white),
                                                ),
                                                onPressed: () async {
                                                  if (cartList.isNotEmpty) {
                                                    if (validateAndSave()) {
                                                      setState(() {
                                                        generateButtonBool = true;
                                                      });
                                                    } else {
                                                      EasyLoading.showInfo('A quantidade é obrigatória');
                                                    }
                                                  } else {
                                                    EasyLoading.showInfo('Selecione o produto');
                                                  }
                                                },
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.settings, color: Colors.white),
                                                    const SizedBox(width: 5.0),
                                                    Text(
                                                      'Gerar',
                                                      style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10.0),
                                        Visibility(
                                          visible: generateButtonBool,
                                          child: const Divider(
                                            thickness: 1.0,
                                            color: kBorderColorTextField,
                                          ),
                                        ),
                                        const SizedBox(height: 20.0),
                                        Center(
                                          child: Visibility(
                                            visible: generateButtonBool && generateButtonBool,
                                            child: SizedBox(
                                              width: 600,
                                              child: Column(
                                                children: [
                                                  Visibility(
                                                    visible: cartList.isNotEmpty,
                                                    child: SizedBox(
                                                      height: 40,
                                                      width: 100,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                                                          backgroundColor: kMainColor,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(30.0),
                                                          ),
                                                          textStyle: kTextStyle.copyWith(color: Colors.white),
                                                        ),
                                                        onPressed: () async {
                                                          if (cartList.isNotEmpty) {
                                                            if (validateAndSave()) {
                                                              await generateBarcodeFunc(
                                                                carts: cartList,
                                                                personalInformationModel: profile.value!,
                                                                context: context,
                                                                site: siteName,
                                                                name: productName,
                                                                code: productCode,
                                                                price: price,
                                                              );
                                                            } else {
                                                              EasyLoading.showInfo('A quantidade é obrigatória');
                                                            }
                                                          } else {
                                                            EasyLoading.showInfo('Selecione o produto');
                                                          }
                                                        },
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            const Icon(Icons.print, color: Colors.white),
                                                            const SizedBox(width: 5.0),
                                                            Text(
                                                              lang.S.of(context).print,
                                                              style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20.0),
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: cartList.length,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      return Wrap(
                                                          crossAxisAlignment: WrapCrossAlignment.start,
                                                          alignment: WrapAlignment.start,
                                                          spacing: 20,
                                                          runSpacing: 0,
                                                          children: List.generate(
                                                            cartList[index].quantity.round(),
                                                            (index2) => Padding(
                                                              padding: const EdgeInsets.only(bottom: 5.0),
                                                              child: Container(
                                                                padding: const EdgeInsets.all(5.0),
                                                                decoration:
                                                                    BoxDecoration(borderRadius: BorderRadius.circular(6.0), border: Border.all(color: kBorderColorTextField)),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Visibility(
                                                                      visible: siteName,
                                                                      child: profile.when(data: (profileData) {
                                                                        return Text(
                                                                          profileData.companyName,
                                                                          style: kTextStyle.copyWith(color: kTitleColor, fontSize: 8),
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
                                                                    ),
                                                                    Visibility(
                                                                      visible: productName,
                                                                      child: Text(
                                                                        cartList[index].productName.toString(),
                                                                        style: kTextStyle.copyWith(color: kTitleColor, fontSize: 8),
                                                                      ),
                                                                    ),
                                                                    Visibility(
                                                                      visible: price,
                                                                      child: Text(
                                                                        '${cartList[index].productPurchasePrice.toString()} $currency',
                                                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 10),
                                                                      ),
                                                                    ),
                                                                    BarcodeWidget(
                                                                      barcode: Barcode.code128(),
                                                                      data: cartList[index].productId,
                                                                      drawText: productCode ? true : false,
                                                                      color: black,
                                                                      width: 140,
                                                                      height: 40,
                                                                      style: kTextStyle.copyWith(color: kTitleColor, fontSize: 8.0),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ));
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
