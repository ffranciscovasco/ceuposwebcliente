import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/Product/product%20barcode/barcode_generate.dart';
import 'package:salespro_admin/Screen/WareHouse/warehouse_details.dart';
import 'package:salespro_admin/Screen/WareHouse/warehouse_model.dart';

import 'package:salespro_admin/model/product_model.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../Provider/expense_category_proivder.dart';
import '../../Provider/product_provider.dart';
import '../../commas.dart';
import '../../const.dart';
import '../../currency.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';
import 'edit_warehouse.dart';

class WareHouseList extends StatefulWidget {
  const WareHouseList({super.key});

  static const String route = '/warehouse_list';

  @override
  State<WareHouseList> createState() => _WareHouseListState();
}

class _WareHouseListState extends State<WareHouseList> {
  int selectedItem = 10;
  int itemCount = 10;
  String searchItem = '';
  bool isRegularSelected = true;

  List<String> title = ['Product List', 'Expired List'];

  String isSelected = 'Product List';

  ScrollController mainScroll = ScrollController();

  String warehouseName = '';
  String address = '';
  DateTime id = DateTime.now();

  bool checkWarehouse({required List<WareHouseModel> allList, required String category}) {
    for (var element in allList) {
      if (element.id == id.toString()) {
        return false;
      }
    }
    return true;
  }

  int selectedIndex = -1;

  void deleteExpenseCategory({required String incomeCategoryName, required WidgetRef updateRef, required BuildContext context}) async {
    EasyLoading.show(status: 'Deleting..');
    String expenseKey = '';
    final userId = await getUserID();
    await FirebaseDatabase.instance.ref(userId).child('Warehouse List').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['warehouseName'].toString() == incomeCategoryName) {
          expenseKey = element.key.toString();
        }
      }
    });
    DatabaseReference ref = FirebaseDatabase.instance.ref("${await getUserID()}/Warehouse List/$expenseKey");
    await ref.remove();
    updateRef.refresh(warehouseProvider);
    EasyLoading.showSuccess('Done').then(
      (value) => Navigator.pop(context),
    );
  }

  void _onRowSelected(int index, bool selected) {
    setState(() {
      selectedIndex = selected ? index : -1;
    });
  }

  num grandTotalStockValue = 0;

  // double grandTotal = calculateGrandTotal(showAbleProducts, productSnap);

  double calculateGrandTotal(List<WareHouseModel> showAbleProducts, List<ProductModel> productSnap) {
    double grandTotal = 0;
    // grandTotal = 0;
    for (var index = 0; index < showAbleProducts.length; index++) {
      for (var element in productSnap) {
        if (showAbleProducts[index].id == element.warehouseId) {
          double stockValue = (double.tryParse(element.productStock) ?? 0) * (double.tryParse(element.productSalePrice) ?? 0);
          grandTotal += stockValue;
        }
      }
    }

    return grandTotal;
  }

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
                  return warehouse.when(
                    data: (snapShot) {
                      List<String> names = [];
                      for (var element in snapShot) {
                        names.add(element.warehouseName.removeAllWhiteSpace().toLowerCase());
                      }
                      return productList.when(
                        data: (productSnap) {
                          List<WareHouseModel> showAbleProducts = [];
                          for (var element in snapShot) {
                            if (element.warehouseName.removeAllWhiteSpace().toLowerCase().contains(searchItem.toLowerCase()) || element.warehouseName.contains(searchItem)) {
                              showAbleProducts.add(element);
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
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  ///________title and add product_______________________________________
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Lista de Armazéns',
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
                                                            hintText: ('Pesquisar com nome'),
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
                                                      InkWell(
                                                        child: Container(
                                                          padding: const EdgeInsets.all(10.0),
                                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: kBlueTextColor),
                                                          child: Row(
                                                            children: [
                                                              const Icon(FeatherIcons.plus, color: kWhite, size: 18.0),
                                                              const SizedBox(width: 5.0),
                                                              Text(
                                                                'Adicionar Armazém',
                                                                style: kTextStyle.copyWith(color: kWhite),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          showDialog(
                                                            barrierDismissible: false,
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return StatefulBuilder(
                                                                builder: (context, setStates) {
                                                                  return Dialog(
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(20.0),
                                                                    ),
                                                                    child: Container(
                                                                      decoration: const BoxDecoration(
                                                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                        color: kWhite,
                                                                      ),
                                                                      width: 600,
                                                                      child: Column(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Padding(
                                                                            padding: const EdgeInsets.all(20.0),
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      'Adicionar novo armazém',
                                                                                      style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 21.0),
                                                                                    ),
                                                                                    const Spacer(),
                                                                                    const Icon(FeatherIcons.x, color: kTitleColor, size: 30.0).onTap(() => Navigator.pop(context))
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(height: 5.0),
                                                                                Divider(
                                                                                  thickness: 1.0,
                                                                                  color: kGreyTextColor.withOpacity(0.2),
                                                                                ),
                                                                                const SizedBox(height: 20.0),
                                                                                Text(
                                                                                  lang.S.of(context).pleaseEnterValidData,
                                                                                  style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                                                                ),
                                                                                const SizedBox(height: 20.0),
                                                                                SizedBox(
                                                                                  width: 580,
                                                                                  child: AppTextField(
                                                                                    onChanged: (value) {
                                                                                      warehouseName = value;
                                                                                    },
                                                                                    showCursor: true,
                                                                                    cursorColor: kTitleColor,
                                                                                    textFieldType: TextFieldType.NAME,
                                                                                    decoration: kInputDecoration.copyWith(
                                                                                      labelText: 'Nome do armazém',
                                                                                      labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                                                                      hintText: 'Digite o nome',
                                                                                      hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(height: 20.0),
                                                                                SizedBox(
                                                                                  width: 580,
                                                                                  child: AppTextField(
                                                                                    onChanged: (value) {
                                                                                      address = value;
                                                                                    },
                                                                                    showCursor: true,
                                                                                    cursorColor: kTitleColor,
                                                                                    textFieldType: TextFieldType.NAME,
                                                                                    decoration: kInputDecoration.copyWith(
                                                                                      labelText: 'Endereço',
                                                                                      labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                                                                      hintText: 'Insira o endereço',
                                                                                      hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(height: 20.0),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Container(
                                                                                      padding: const EdgeInsets.all(10.0),
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                                        color: Colors.red,
                                                                                      ),
                                                                                      width: 150,
                                                                                      child: Column(
                                                                                        children: [
                                                                                          Text(
                                                                                            lang.S.of(context).cancel,
                                                                                            style: kTextStyle.copyWith(color: kWhite),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ).onTap(() {
                                                                                      Navigator.pop(context);
                                                                                    }),
                                                                                    const SizedBox(width: 20),
                                                                                    InkWell(
                                                                                      onTap: () async {
                                                                                        if (warehouseName != '' &&
                                                                                            !names.contains(warehouseName.toLowerCase().removeAllWhiteSpace())) {
                                                                                          WareHouseModel warehouse = WareHouseModel(
                                                                                              warehouseName: warehouseName, warehouseAddress: address, id: id.toString());
                                                                                          try {
                                                                                            EasyLoading.show(status: 'Processando...', dismissOnTap: false);
                                                                                            final DatabaseReference productInformationRef =
                                                                                                FirebaseDatabase.instance.ref().child(await getUserID()).child('Warehouse List');
                                                                                            await productInformationRef.push().set(warehouse.toJson());
                                                                                            EasyLoading.showSuccess('Adicionado com sucesso',
                                                                                                duration: const Duration(milliseconds: 500));

                                                                                            ///____provider_refresh____________________________________________
                                                                                            ref.refresh(warehouseProvider);

                                                                                            Future.delayed(const Duration(milliseconds: 100), () {
                                                                                              Navigator.pop(context);
                                                                                            });
                                                                                          } catch (e) {
                                                                                            EasyLoading.dismiss();
                                                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                                                                          }
                                                                                        } else if (names.contains(warehouseName.toLowerCase().removeAllWhiteSpace())) {
                                                                                          EasyLoading.showError('O nome da categoria já existe');
                                                                                        } else {
                                                                                          EasyLoading.showError('Insira o nome do armazém');
                                                                                        }
                                                                                      },
                                                                                      child: Container(
                                                                                        padding: const EdgeInsets.all(10.0),
                                                                                        decoration: BoxDecoration(
                                                                                          borderRadius: BorderRadius.circular(5.0),
                                                                                          color: kGreenTextColor,
                                                                                        ),
                                                                                        width: 150,
                                                                                        child: Column(
                                                                                          children: [
                                                                                            Text(
                                                                                              lang.S.of(context).saveAndPublish,
                                                                                              style: kTextStyle.copyWith(color: kWhite),
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
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          );
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  Container(
                                                    height: 80,
                                                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 100.0, 10.0),
                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), color: const Color(0xFFD6FFDF)),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          // '$currency${grandTotal.toStringAsFixed(2)}',
                                                          '${myFormat.format(double.tryParse(calculateGrandTotal(showAbleProducts, productSnap).toString()) ?? 0)} $currency',
                                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                                        ),
                                                        const SizedBox(height: 4.0),
                                                        Text(
                                                          'Valor total',
                                                          style: kTextStyle.copyWith(color: kGreyTextColor),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20.0),
                                                  SizedBox(
                                                    height: (MediaQuery.of(context).size.height - 240).isNegative ? 0 : MediaQuery.of(context).size.height - 240,
                                                    width: MediaQuery.of(context).size.width < 1275 ? 1275 - 240 : MediaQuery.of(context).size.width - 240,
                                                    child: SingleChildScrollView(
                                                      child: DataTable(
                                                        border: const TableBorder(
                                                          horizontalInside: BorderSide(
                                                            width: 1,
                                                            color: kBorderColorTextField,
                                                          ),
                                                        ),
                                                        showCheckboxColumn: false,
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
                                                          const DataColumn(label: Text('Nome do armazém')),
                                                          const DataColumn(label: Text('Endereço')),
                                                          const DataColumn(label: Text('Quantidade de estoque')),
                                                          const DataColumn(label: Text('Valor do Estoque')),
                                                          const DataColumn(label: Text('')),
                                                          DataColumn(
                                                              label: Text(
                                                            'Ação',
                                                            style: kTextStyle.copyWith(color: Colors.black, overflow: TextOverflow.ellipsis),
                                                          )),
                                                        ],
                                                        rows: List.generate(
                                                          showAbleProducts.length,
                                                          (index) {
                                                            num stockValue = 0;
                                                            num totalStock = 0;
                                                            for (var element in productSnap) {
                                                              if (showAbleProducts[index].id == element.warehouseId) {
                                                                stockValue += (num.tryParse(element.productStock) ?? 0) * (num.tryParse(element.productSalePrice) ?? 0);
                                                                totalStock += (num.tryParse(element.productStock) ?? 0);
                                                              }
                                                            }
                                                            return DataRow(
                                                              cells: [
                                                                DataCell(
                                                                  Text('${index + 1}'),
                                                                ),
                                                                DataCell(
                                                                  Text(
                                                                    showAbleProducts[index].warehouseName,
                                                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  Text(
                                                                    showAbleProducts[index].warehouseAddress,
                                                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  Text(
                                                                    totalStock.toString(),
                                                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  Text(
                                                                    '${stockValue.toString()} $currency',
                                                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  Text(
                                                                    '',
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
                                                                              child: GestureDetector(
                                                                                onTap: () => Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => WareHouseDetails(
                                                                                        warehouseID: showAbleProducts[index].id,
                                                                                        warehouseName: showAbleProducts[index].warehouseName),
                                                                                  ),
                                                                                ),
                                                                                child: Row(
                                                                                  children: [
                                                                                    const Icon(Icons.remove_red_eye, size: 18.0, color: kTitleColor),
                                                                                    const SizedBox(width: 4.0),
                                                                                    Text(
                                                                                      'Visualizar',
                                                                                      style: kTextStyle.copyWith(color: kTitleColor),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),

                                                                            PopupMenuItem(
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  snapShot[index].warehouseName == 'InHouse'
                                                                                      ? EasyLoading.showInfo('InHouse não pode ser editado')
                                                                                      : showDialog(
                                                                                          barrierDismissible: false,
                                                                                          context: context,
                                                                                          builder: (BuildContext context) {
                                                                                            return StatefulBuilder(
                                                                                              builder: (context, setStates) {
                                                                                                return Dialog(
                                                                                                  shape: RoundedRectangleBorder(
                                                                                                    borderRadius: BorderRadius.circular(20.0),
                                                                                                  ),
                                                                                                  child: EditWarehouse(
                                                                                                    listOfWarehouse: showAbleProducts,
                                                                                                    warehouseModel: showAbleProducts[index],
                                                                                                    menuContext: bc,
                                                                                                  ),
                                                                                                );
                                                                                              },
                                                                                            );
                                                                                          },
                                                                                        );
                                                                                },
                                                                                child: Row(
                                                                                  children: [
                                                                                    const Icon(Icons.edit, size: 18.0, color: kTitleColor),
                                                                                    const SizedBox(width: 4.0),
                                                                                    Text(
                                                                                      lang.S.of(context).edit,
                                                                                      style: kTextStyle.copyWith(color: kTitleColor),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),

                                                                            ///____________Delete___________________________________________
                                                                            PopupMenuItem(
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  if (checkWarehouse(allList: warehouse.value!, category: showAbleProducts[index].warehouseName)) {
                                                                                    showAbleProducts[index].warehouseName == 'InHouse'
                                                                                        ? EasyLoading.showInfo('InHouse não pode ser Apagado')
                                                                                        : showDialog(
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
                                                                                                                    style: TextStyle(color: Colors.white),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                              onTap: () {
                                                                                                                deleteExpenseCategory(
                                                                                                                  incomeCategoryName: showAbleProducts[index].warehouseName,
                                                                                                                  updateRef: ref,
                                                                                                                  context: dialogContext,
                                                                                                                );
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
                                                                                    EasyLoading.showError('Esta categoria não pode ser excluída');
                                                                                  }
                                                                                },
                                                                                child: Row(
                                                                                  children: [
                                                                                    const Icon(Icons.delete, size: 18.0, color: kTitleColor),
                                                                                    const SizedBox(width: 4.0),
                                                                                    Text(
                                                                                      lang.S.of(context).delete,
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
                                                                          child: const Icon(
                                                                            Icons.more_vert_sharp,
                                                                            size: 18,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                              selected: selectedIndex == 0,
                                                              mouseCursor: MaterialStateMouseCursor.clickable,
                                                              color: _onRowSelected == selectedIndex ? MaterialStateProperty.all<Color>(Colors.green) : null,
                                                              onSelectChanged: (selected) {
                                                                _onRowSelected(0, selected!);
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        WareHouseDetails(warehouseID: snapShot[index].id, warehouseName: snapShot[index].warehouseName),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
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
