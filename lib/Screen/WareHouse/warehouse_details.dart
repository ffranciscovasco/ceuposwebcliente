import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/Product/product%20barcode/barcode_generate.dart';
import 'package:salespro_admin/Screen/WareHouse/warehouse_model.dart';

import 'package:salespro_admin/model/product_model.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../Provider/expense_category_proivder.dart';
import '../../Provider/product_provider.dart';
import '../../commas.dart';
import '../../const.dart';
import '../../currency.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Constant Data/export_button.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';
import 'edit_warehouse.dart';

class WareHouseDetails extends StatefulWidget {
  const WareHouseDetails({super.key, required this.warehouseID, required this.warehouseName});

  final String warehouseID;
  final String warehouseName;

  static const String route = '/warehouse_details';

  @override
  State<WareHouseDetails> createState() => _WareHouseDetailsState();
}

class _WareHouseDetailsState extends State<WareHouseDetails> {
  int selectedItem = 10;
  int itemCount = 10;
  String searchItem = '';
  bool isRegularSelected = true;

  List<String> title = ['Product List', 'Expired List'];

  String isSelected = 'Product List';

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
    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          backgroundColor: kDarkWhite,
          body: Scrollbar(
            controller: mainScroll,
            child: SingleChildScrollView(
              controller: mainScroll,
              scrollDirection: Axis.horizontal,
              child: Consumer(
                builder: (_, ref, watch) {
                  final warehouse = ref.watch(warehouseProvider);
                  AsyncValue<List<ProductModel>> productList = ref.watch(productProvider);
                  return productList.when(
                    data: (snapShot) {
                      List<ProductModel> showAbleProducts = [];
                      for (var element in snapShot) {
                        if (!isRegularSelected) {
                          if (((element.productName.removeAllWhiteSpace().toLowerCase().contains(searchItem.toLowerCase()) || element.productName.contains(searchItem))) &&
                              element.expiringDate != null &&
                              ((DateTime.tryParse(element.expiringDate ?? '') ?? DateTime.now()).isBefore(DateTime.now().add(const Duration(days: 7))))) {
                            if (element.warehouseId == widget.warehouseID) {
                              showAbleProducts.add(element);
                            }
                          }
                        } else {
                          if (searchItem != '' &&
                              (element.productName.removeAllWhiteSpace().toLowerCase().contains(searchItem.toLowerCase()) || element.productName.contains(searchItem))) {
                            if (element.warehouseId == widget.warehouseID) {
                              showAbleProducts.add(element);
                            }
                          } else if (searchItem == '') {
                            if (element.warehouseId == widget.warehouseID) {
                              showAbleProducts.add(element);
                            }
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
                              index: 4,
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
                                                  Text(
                                                    widget.warehouseName,
                                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                                  ),
                                                  const Spacer(),

                                                  ///___________search________________________________________________-
                                                  Container(
                                                    height: 40.0,
                                                    width: 300,
                                                    decoration:
                                                        BoxDecoration(borderRadius: BorderRadius.circular(30.0), border: Border.all(color: kGreyTextColor.withOpacity(0.1))),
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
                                                        hintText: ('Pesquise com nome do produto'),
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
                                                                    ),
                                                                  ),
                                                                ),
                                                                const DataColumn(label: Text('Categoria')),
                                                                const DataColumn(label: Text('Cliente')),
                                                                const DataColumn(label: Text('Distribuidora')),
                                                                const DataColumn(label: Text('Atacado')),
                                                                const DataColumn(label: Text('Estoque')),
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
                                                                          "${myFormat.format(double.tryParse(product.productSalePrice) ?? 0)} $currency",
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
                                                                          myFormat.format(double.tryParse(product.productStock) ?? 0),
                                                                          style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                          maxLines: 2,
                                                                          overflow: TextOverflow.ellipsis,
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
                                                                      child: const Center(child: Text('Proximo')),
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
                                  const SizedBox(height: 20.0),
                                  Visibility(visible: MediaQuery.of(context).size.height != 0, child: const Footer()),
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    },
                    error: (e, stack) {
                      return Center(
                        child: Text(e.toString()),
                      );
                    },
                    loading: () {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
