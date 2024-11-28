import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/WareHouse/warehouse_model.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../const.dart';
import '../Widgets/Constant Data/constant.dart';

class EditWarehouse extends StatefulWidget {
  const EditWarehouse({Key? key, required this.listOfWarehouse, required this.warehouseModel, required this.menuContext}) : super(key: key);

  final List<WareHouseModel> listOfWarehouse;
  final WareHouseModel warehouseModel;
  final BuildContext menuContext;

  @override
  State<EditWarehouse> createState() => _EditWarehouseState();
}

class _EditWarehouseState extends State<EditWarehouse> {
  String warehouseAddress = '';
  String houseName = '';

  String expenseKey = '';

  void getExpenseKey() async {
    final userId = await getUserID();
    await FirebaseDatabase.instance.ref(userId).child('Warehouse List').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['warehouseName'].toString() == widget.warehouseModel.warehouseName) {
          expenseKey = element.key.toString();
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkCurrentUserAndRestartApp();
    warehouseAddress = widget.warehouseModel.warehouseAddress;
    houseName = widget.warehouseModel.warehouseName;
    getExpenseKey();
  }

  @override
  Widget build(BuildContext context) {
    List<String> names = [];
    for (var element in widget.listOfWarehouse) {
      names.add(element.warehouseName.removeAllWhiteSpace().toLowerCase());
    }
    return Consumer(
      builder: (context, ref, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
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
                              lang.S.of(context).entercategoryName,
                              style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 21.0),
                            ),
                            const Spacer(),
                            const Icon(FeatherIcons.x, color: kTitleColor, size: 30.0).onTap(() {
                              Navigator.pop(context);
                              Navigator.pop(widget.menuContext);
                            })
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
                            initialValue: houseName,
                            onChanged: (value) {
                              houseName = value;
                            },
                            showCursor: true,
                            cursorColor: kTitleColor,
                            textFieldType: TextFieldType.NAME,
                            decoration: kInputDecoration.copyWith(
                              labelText: lang.S.of(context).categoryName,
                              labelStyle: kTextStyle.copyWith(color: kTitleColor),
                              hintText: lang.S.of(context).entercategoryName,
                              hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        SizedBox(
                          width: 580,
                          child: AppTextField(
                            initialValue: warehouseAddress,
                            onChanged: (value) {
                              warehouseAddress = value;
                            },
                            showCursor: true,
                            cursorColor: kTitleColor,
                            textFieldType: TextFieldType.NAME,
                            decoration: kInputDecoration.copyWith(
                              labelText: 'Descrição',
                              labelStyle: kTextStyle.copyWith(color: kTitleColor),
                              hintText: 'Adicionar descrição...',
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
                              Navigator.pop(widget.menuContext);
                            }),
                            const SizedBox(width: 20),
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: kGreenTextColor,
                              ),
                              width: 150,
                              child: Column(
                                children: [
                                  Text(
                                    lang.S.of(context).saveAndPublished,
                                    style: kTextStyle.copyWith(color: kWhite),
                                  ),
                                ],
                              ),
                            ).onTap(() {
                              WareHouseModel warehouse = WareHouseModel(warehouseName: houseName, warehouseAddress: warehouseAddress, id: widget.warehouseModel.id);
                              if (houseName != '' && houseName == widget.warehouseModel.warehouseName ? true : !names.contains(houseName.toLowerCase().removeAllWhiteSpace())) {
                                setState(() async {
                                  try {
                                    EasyLoading.show(status: 'Processando...', dismissOnTap: false);
                                    final DatabaseReference productInformationRef =
                                        FirebaseDatabase.instance.ref().child(await getUserID()).child('Warehouse List').child(expenseKey);
                                    await productInformationRef.set(warehouse.toJson());
                                    EasyLoading.showSuccess('Editado com sucesso', duration: const Duration(milliseconds: 500));

                                    ///____provider_refresh____________________________________________
                                    ref.refresh(warehouseProvider);

                                    Future.delayed(const Duration(milliseconds: 100), () {
                                      Navigator.pop(context);
                                      Navigator.pop(widget.menuContext);
                                    });
                                  } catch (e) {
                                    EasyLoading.dismiss();
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                  }
                                });
                              } else if (names.contains(houseName.toLowerCase().removeAllWhiteSpace())) {
                                EasyLoading.showError('Armazém já existe');
                              } else {
                                EasyLoading.showError('O nome não pode ficar vazio');
                              }
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
