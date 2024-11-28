import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/HRM/Designation/model/designation_model.dart';
import 'package:salespro_admin/Screen/HRM/Designation/provider/designation_provider.dart';
import 'package:salespro_admin/Screen/HRM/Designation/repo/designation_repo.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../../const.dart';
import '../../Widgets/Constant Data/constant.dart';
import '../../Widgets/Constant Data/export_button.dart';
import '../../Widgets/Footer/footer.dart';
import '../../Widgets/Sidebar/sidebar_widget.dart';
import '../../Widgets/TopBar/top_bar_widget.dart';
import '../widgets/deleteing_alart_dialog.dart';
import 'add_designation.dart';

class DesignationListScreen extends StatefulWidget {
  const DesignationListScreen({super.key});

  static const String route = '/HRM/designation_List';

  @override
  State<DesignationListScreen> createState() => _DesignationListScreenState();
}

class _DesignationListScreenState extends State<DesignationListScreen> {
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
      child: Consumer(
        builder: (context, ref, child) {
          final designations = ref.watch(designationProvider);
          return Scaffold(
            backgroundColor: kDarkWhite,
            body: Scrollbar(
              controller: mainScroll,
              child: SingleChildScrollView(
                controller: mainScroll,
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 240,
                      child: SideBarWidget(
                        index: 18,
                        subManu: 'Designation List',
                        isTab: false,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width < 1275 ? 1275 - 240 : MediaQuery.of(context).size.width - 240,
                      decoration: const BoxDecoration(color: kDarkWhite),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //_______________________________top_bar____________________________
                            const TopBar(),

                            designations.when(data: (designationList) {
                              List<DesignationModel> reverseAllIncomeCategory = designationList.reversed.toList();
                              List<DesignationModel> showIncomeCategory = [];
                              for (var element in reverseAllIncomeCategory) {
                                if (searchItem != '' && (element.designation.contains(searchItem) || element.designation.contains(searchItem))) {
                                  showIncomeCategory.add(element);
                                } else if (searchItem == '') {
                                  showIncomeCategory.add(element);
                                }
                              }
                              return Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: kWhite),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Lista de Designação',
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
                                                hintText: 'Pesquisar....',
                                                hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                                border: InputBorder.none,
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
                                          const SizedBox(width: 20.0),
                                          Container(
                                            padding: const EdgeInsets.all(5.0),
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: kBlueTextColor),
                                            child: Container(
                                              padding: const EdgeInsets.all(5.0),
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: kBlueTextColor),
                                              child: Row(
                                                children: [
                                                  const Icon(FeatherIcons.plus, color: kWhite, size: 18.0),
                                                  const SizedBox(width: 5.0),
                                                  Text(
                                                    'Adicionar designação',
                                                    style: kTextStyle.copyWith(color: kWhite),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ).onTap(
                                            () => showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return StatefulBuilder(
                                                  builder: (context, setStates) {
                                                    return Dialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(20.0),
                                                      ),
                                                      child: AddDesignationScreen(listOfIncomeCategory: designationList),
                                                    );
                                                  },
                                                );
                                              },
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

                                      ///__________expense_LIst____________________________________________________________________
                                      showIncomeCategory.isNotEmpty
                                          ? SizedBox(
                                              height: (MediaQuery.of(context).size.height - 255).isNegative ? 0 : MediaQuery.of(context).size.height - 255,
                                              width: double.infinity,
                                              child: SingleChildScrollView(
                                                child: DataTable(
                                                  headingRowColor: MaterialStateProperty.all(kbgColor),
                                                  showBottomBorder: false,
                                                  columnSpacing: 0.0,
                                                  columns: [
                                                    DataColumn(
                                                      label: Text(
                                                        'No',
                                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: SizedBox(
                                                        width: 100.0,
                                                        child: Text(
                                                          'Categoria',
                                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        lang.S.of(context).description,
                                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      numeric: true,
                                                      label: Text(lang.S.of(context).action, style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold)),
                                                    ),
                                                  ],
                                                  rows: List.generate(
                                                    showIncomeCategory.length,
                                                    (index) => DataRow(cells: [
                                                      DataCell(
                                                        Text((index + 1).toString()),
                                                      ),
                                                      DataCell(
                                                        Text(showIncomeCategory[index].designation, style: kTextStyle.copyWith(color: kGreyTextColor)),
                                                      ),
                                                      DataCell(
                                                        Text(showIncomeCategory[index].designationDescription, style: kTextStyle.copyWith(color: kGreyTextColor)),
                                                      ),

                                                      ///__________action_menu__________________________________________________________
                                                      DataCell(
                                                        Theme(
                                                          data: ThemeData(highlightColor: dropdownItemColor, focusColor: dropdownItemColor, hoverColor: dropdownItemColor),
                                                          child: PopupMenuButton(
                                                            surfaceTintColor: Colors.white,
                                                            icon: const Icon(FeatherIcons.moreVertical, size: 18.0),
                                                            padding: EdgeInsets.zero,
                                                            itemBuilder: (BuildContext bc) => [
                                                              ///_________Edit___________________________________________
                                                              PopupMenuItem(
                                                                child: GestureDetector(
                                                                  onTap: () async {
                                                                    await showDialog(
                                                                      barrierDismissible: false,
                                                                      context: context,
                                                                      builder: (BuildContext context) {
                                                                        return StatefulBuilder(
                                                                          builder: (context, setStates) {
                                                                            return Dialog(
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(20.0),
                                                                              ),
                                                                              child: AddDesignationScreen(
                                                                                listOfIncomeCategory: designationList,
                                                                                designationModel: showIncomeCategory[index],
                                                                              ),
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                    );

                                                                    Navigator.pop(bc);
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
                                                                  onTap: () async {
                                                                    if (await showDeleteConfirmationDialog(context: context, itemName: 'designation')) {
                                                                      bool result = await DesignationRepository().deleteDesignation(id: showIncomeCategory[index].id);
                                                                      if (result) {
                                                                        ref.refresh(designationProvider);
                                                                      }
                                                                    }
                                                                    Navigator.pop(bc);
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
                                                          ),
                                                        ),
                                                      ),
                                                    ]),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const EmptyWidget(title: 'Nenhum dado encontrado'),
                                    ],
                                  ),
                                ),
                              );

                              // return ExpensesTableWidget(expenses: allExpenses);
                            }, error: (e, stack) {
                              return Center(
                                child: Text(e.toString()),
                              );
                            }, loading: () {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }),
                            Visibility(visible: MediaQuery.of(context).size.height != 0, child: const Footer()),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
