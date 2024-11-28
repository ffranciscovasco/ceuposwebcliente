import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/HRM/Designation/repo/designation_repo.dart';
import 'package:salespro_admin/Screen/HRM/employees/provider/designation_provider.dart';
import 'package:salespro_admin/Screen/HRM/employees/repo/employee_repo.dart';
import 'package:salespro_admin/Screen/HRM/salaries%20list/pay_salary_screen.dart';
import 'package:salespro_admin/Screen/HRM/salaries%20list/model/pay_salary_model.dart';
import 'package:salespro_admin/Screen/HRM/salaries%20list/provider/salary_provider.dart';
import 'package:salespro_admin/Screen/HRM/salaries%20list/repo/salary_repo.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../../const.dart';
import '../../Widgets/Constant Data/constant.dart';
import '../../Widgets/Constant Data/export_button.dart';
import '../../Widgets/Footer/footer.dart';
import '../../Widgets/Sidebar/sidebar_widget.dart';
import '../../Widgets/TopBar/top_bar_widget.dart';
import '../employees/model/employee_model.dart';
import '../widgets/deleteing_alart_dialog.dart';

class SalariesListScreen extends StatefulWidget {
  const SalariesListScreen({super.key});

  static const String route = '/HRM/salaries_List';

  @override
  State<SalariesListScreen> createState() => _SalariesListScreenState();
}

class _SalariesListScreenState extends State<SalariesListScreen> {
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
          final employee = ref.watch(employeeProvider);
          final salary = ref.watch(salaryProvider);
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
                        index: 19,
                        subManu: 'Salaries List',
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

                            salary.when(data: (employeeList) {
                              List<PaySalaryModel> reverseAllIncomeCategory = employeeList.reversed.toList();
                              List<PaySalaryModel> showIncomeCategory = [];
                              for (var element in reverseAllIncomeCategory) {
                                if (searchItem != '' && (element.employeeName.contains(searchItem) || element.employeeName.contains(searchItem))) {
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
                                            'Lista de Salários',
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

                                          employee.when(
                                            data: (employees) {
                                              return GestureDetector(
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
                                                            child: PaySalaryScreen(
                                                              listOfEmployees: employees,
                                                              ref: ref,
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Container(
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
                                                          'Pagar Salário',
                                                          style: kTextStyle.copyWith(color: kWhite),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            error: (error, stackTrace) {
                                              return const Center(
                                                child: Text('Um erro acusado'),
                                              );
                                            },
                                            loading: () {
                                              return const Center(
                                                child: CircularProgressIndicator(),
                                              );
                                            },
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
                                                          'Funcionário',
                                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Mês',
                                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Salário',
                                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Valor pago',
                                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Data de pagamento',
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
                                                        Text(showIncomeCategory[index].employeeName, style: kTextStyle.copyWith(color: kGreyTextColor)),
                                                      ),
                                                      DataCell(
                                                        Text('${showIncomeCategory[index].month}-${showIncomeCategory[index].year}', style: kTextStyle.copyWith(color: kGreyTextColor)),
                                                      ),
                                                      DataCell(
                                                        Text(showIncomeCategory[index].netSalary.toString(), style: kTextStyle.copyWith(color: kGreyTextColor)),
                                                      ),
                                                      DataCell(
                                                        Text(showIncomeCategory[index].paySalary.toString(), style: kTextStyle.copyWith(color: kGreyTextColor)),
                                                      ),
                                                      DataCell(
                                                        Text(DateFormat.yMd().format(showIncomeCategory[index].payingDate), style: kTextStyle.copyWith(color: kGreyTextColor)),
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
                                                                              child: PaySalaryScreen(
                                                                                listOfEmployees: employee.value??[],
                                                                                payedSalary: showIncomeCategory[index],
                                                                                ref: ref,
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
                                                                    if (await showDeleteConfirmationDialog(context: context, itemName: 'salary')) {
                                                                      bool result = await SalaryRepository().deletePaidSalary(id: showIncomeCategory[index].id);
                                                                      if (result) {
                                                                        ref.refresh(salaryProvider);
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
