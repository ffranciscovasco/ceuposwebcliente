import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/commas.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../Provider/product_provider.dart';
import '../../model/product_model.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Constant Data/export_button.dart';
import '../Widgets/noDataFound.dart';

class CurrentStockWidget extends StatefulWidget {
  const CurrentStockWidget({Key? key}) : super(key: key);

  @override
  State<CurrentStockWidget> createState() => _CurrentStockWidgetState();
}

class _CurrentStockWidgetState extends State<CurrentStockWidget> {
  String searchItem = '';
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, __) {
        AsyncValue<List<ProductModel>> stockData = ref.watch(productProvider);
        return stockData.when(data: (report) {
          List<ProductModel> reTransaction = [];
          for (var element in report) {
            if (element.productName.removeAllWhiteSpace().toLowerCase().contains(searchItem.removeAllWhiteSpace().toLowerCase())) {
              reTransaction.add(element);
            }
          }
          return Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lang.S.of(context).stockReport,
                            style: kTextStyle.copyWith(color: kTitleColor, fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),

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
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        thickness: 1.0,
                        color: kGreyTextColor.withOpacity(0.2),
                      ),
                      reTransaction.isNotEmpty
                          ? SizedBox(
                              height: (MediaQuery.of(context).size.height - 240).isNegative ? 0 : MediaQuery.of(context).size.height - 240,
                              width: double.infinity,
                              child: SingleChildScrollView(
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
                                      label: Text(lang.S.of(context).PRODUCTNAME, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        lang.S.of(context).CATEGORY,
                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(lang.S.of(context).PRICE, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                                    ),
                                    DataColumn(
                                      label: Text(lang.S.of(context).QTY, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                                    ),
                                    DataColumn(
                                      label: Text('Armazém', style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                                    ),
                                    DataColumn(
                                      label: Text(lang.S.of(context).STATUS, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                                    ),
                                    DataColumn(
                                      label: Text(lang.S.of(context).TOTALVALUE, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                                    ),
                                    // const DataColumn(
                                    //   label: Icon(FeatherIcons.settings, color: kGreyTextColor),
                                    // ),
                                  ],
                                  rows: List.generate(
                                    reTransaction.length,
                                    (index) => DataRow(
                                      cells: [
                                        DataCell(
                                          Text((index + 1).toString()),
                                        ),
                                        DataCell(
                                          GestureDetector(
                                            onTap: () {},
                                            child: SizedBox(
                                              width: 180,
                                              child: Text(
                                                reTransaction[index].productName,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: kTextStyle.copyWith(color: kGreyTextColor),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          GestureDetector(
                                            onTap: () {},
                                            child: SizedBox(
                                              width: 100,
                                              child: Text(
                                                reTransaction[index].productCategory,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: kTextStyle.copyWith(color: kGreyTextColor),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          GestureDetector(
                                            onTap: () {},
                                            child: Text(
                                              myFormat.format(double.tryParse(reTransaction[index].productSalePrice) ?? 0),
                                              style: kTextStyle.copyWith(color: kGreyTextColor),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          GestureDetector(
                                            onTap: () {},
                                            child: Text(
                                              reTransaction[index].productStock,
                                              style: kTextStyle.copyWith(color: kGreyTextColor),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          GestureDetector(
                                            onTap: () {},
                                            child: Text(
                                              reTransaction[index].warehouseName,
                                              style: kTextStyle.copyWith(color: kGreyTextColor),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          GestureDetector(
                                              onTap: () {},
                                              child: Text(reTransaction[index].productStock.toString().toInt() < 50 ? 'Baixo' : 'Alto',
                                                  style: kTextStyle.copyWith(
                                                    color: reTransaction[index].productStock.toInt() < 50 ? Colors.red : kGreyTextColor,
                                                  ))),
                                        ),
                                        DataCell(
                                          GestureDetector(
                                              onTap: () {},
                                              child: Text(
                                                  myFormat.format(
                                                      double.tryParse((reTransaction[index].productSalePrice.toInt() * reTransaction[index].productStock.toInt()).toString()) ?? 0),
                                                  style: kTextStyle.copyWith(color: kGreyTextColor))),
                                        ),
                                        // DataCell(
                                        //   PopupMenuButton(
                                        //     icon: const Icon(FeatherIcons.moreVertical, size: 18.0),
                                        //     padding: EdgeInsets.zero,
                                        //     itemBuilder: (BuildContext bc) => [
                                        //       PopupMenuItem(
                                        //         child: GestureDetector(
                                        //           onTap: () {},
                                        //           child: Row(
                                        //             children: [
                                        //               const Icon(MdiIcons.printer, size: 18.0, color: kTitleColor),
                                        //               const SizedBox(width: 4.0),
                                        //               Text(
                                        //                 'Print',
                                        //                 style: kTextStyle.copyWith(color: kTitleColor),
                                        //               ),
                                        //             ],
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ],
                                        //     onSelected: (value) {
                                        //       Navigator.pushNamed(context, '$value');
                                        //     },
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : EmptyWidget(title: lang.S.of(context).noReportFound)
                    ],
                  ),
                )
              ],
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
        });
      },
    );
  }
}
