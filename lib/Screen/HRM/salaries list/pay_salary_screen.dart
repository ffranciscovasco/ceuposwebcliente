import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/HRM/salaries%20list/provider/salary_provider.dart';
import 'package:salespro_admin/Screen/HRM/salaries%20list/repo/salary_repo.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../../const.dart';
import '../../Widgets/Constant Data/constant.dart';
import '../employees/model/employee_model.dart';
import 'model/pay_salary_model.dart';

class PaySalaryScreen extends StatefulWidget {
  PaySalaryScreen({
    super.key,
    required this.listOfEmployees,
    this.payedSalary,
    required this.ref,
  });

  final List<EmployeeModel> listOfEmployees;
  PaySalaryModel? payedSalary;
  final WidgetRef ref;

  @override
  State<PaySalaryScreen> createState() => _PaySalaryScreenState();
}

class _PaySalaryScreenState extends State<PaySalaryScreen> {
  List<String> yearList = List.generate(111, (index) => (1990 + index).toString());
  List<String> paymentItem = ['Cash', 'Banco', 'M-pesa', 'E-mola'];
  String? selectedPaymentOption = 'Cash';

  List<String> monthList = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  final TextEditingController paySalaryController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedYear = DateTime.now().year.toString();
  String? selectedMonth;
  EmployeeModel? selectedEmployee;

  @override
  void initState() {
    super.initState();
    checkCurrentUserAndRestartApp();

    if (widget.payedSalary != null) {
      paySalaryController.text = widget.payedSalary?.paySalary.toString() ?? '';
      notesController.text = widget.payedSalary?.note ?? '';
      selectedMonth = widget.payedSalary?.month;
      selectedYear = widget.payedSalary?.year;
      selectedPaymentOption = widget.payedSalary?.paymentType;
      for (var element in widget.listOfEmployees) {
        if (element.id == widget.payedSalary?.employmentId) {
          setState(() {
            selectedEmployee = element;
          });
          return;
        }
      }
    } else {
      setState(() {
        selectedMonth = monthList[DateTime.now().month - 1];
      });
    }
  }

  @override
  void dispose() {
    paySalaryController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: Form(
                key: formKey,
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
                                'Pagar Salário',
                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 21.0),
                              ),
                              const Spacer(),
                              const Icon(FeatherIcons.x, color: kTitleColor, size: 30.0).onTap(() => Navigator.pop(context)),
                            ],
                          ),
                          const SizedBox(height: 20.0),

                          ///________Employee_and_Salary_______________________
                          Row(
                            children: [
                              SizedBox(
                                  width: 270,
                                  child: DropdownButtonFormField<EmployeeModel>(
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Funcionário necessário';
                                      }
                                      return null;
                                    },
                                    decoration: kInputDecoration.copyWith(
                                      labelText: 'Selecione Funcionário',
                                      labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                      hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                    ),
                                    value: selectedEmployee,
                                    hint: const Text(
                                      'Selecione Funcionário',
                                      style: TextStyle(color: Colors.black54, fontSize: 16),
                                    ),
                                    items: widget.listOfEmployees
                                        .map(
                                          (items) => DropdownMenuItem(
                                            value: items,
                                            child: Text(items.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedEmployee = value;
                                      });
                                    },
                                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                    dropdownColor: Colors.white,
                                    style: const TextStyle(color: Colors.black, fontSize: 16),
                                  )),
                              const SizedBox(width: 20.0),
                              _buildTextField(
                                controller: paySalaryController,
                                label: 'Valor a ser pago',
                                width: 270,
                                hint: 'Por favor insira o valor do salário',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Insira o valor do salário pago';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),

                          ///________Year_and_Months_________________________
                          Row(
                            children: [
                              // Year dropdown
                              SizedBox(
                                width: 270,
                                child: DropdownButtonFormField<String>(
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Ano obrigatório';
                                    }
                                    return null;
                                  },
                                  decoration: kInputDecoration.copyWith(
                                    labelText: 'Selecione o ano',
                                    labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                    hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                  ),
                                  value: selectedYear,
                                  hint: const Text(
                                    'Selecione o ano',
                                    style: TextStyle(color: Colors.black54, fontSize: 16),
                                  ),
                                  items: yearList
                                      .map(
                                        (year) => DropdownMenuItem(
                                          value: year,
                                          child: Text(year),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedYear = value!;
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  dropdownColor: Colors.white,
                                  style: const TextStyle(color: Colors.black, fontSize: 16),
                                ),
                              ),
                              const SizedBox(width: 20.0),

                              SizedBox(
                                width: 270,
                                child: DropdownButtonFormField<String>(
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Mês necessário';
                                    }
                                    return null;
                                  },
                                  decoration: kInputDecoration.copyWith(
                                    labelText: 'Selecione o mês',
                                    labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                    hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                  ),
                                  value: selectedMonth,
                                  hint: const Text(
                                    'Selecione o mês',
                                    style: TextStyle(color: Colors.black54, fontSize: 16),
                                  ),
                                  items: monthList
                                      .map(
                                        (month) => DropdownMenuItem(
                                          value: month,
                                          child: Text(month),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedMonth = value!;
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  dropdownColor: Colors.white,
                                  style: const TextStyle(color: Colors.black, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),

                          ///____________Payment Type_and_designation________________________
                          Row(
                            children: [
                              SizedBox(
                                width: 270,
                                child: DropdownButtonFormField<String>(
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Mês necessário';
                                    }
                                    return null;
                                  },
                                  decoration: kInputDecoration.copyWith(
                                    labelText: 'Selecione o mês',
                                    labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                    hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                  ),
                                  value: selectedPaymentOption,
                                  hint: const Text(
                                    'Selecione o mês',
                                    style: TextStyle(color: Colors.black54, fontSize: 16),
                                  ),
                                  items: paymentItem
                                      .map(
                                        (month) => DropdownMenuItem(
                                          value: month,
                                          child: Text(month),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedPaymentOption = value!;
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  dropdownColor: Colors.white,
                                  style: const TextStyle(color: Colors.black, fontSize: 16),
                                ),
                              ),
                              const SizedBox(width: 20),
                              _buildTextField(
                                controller: notesController,
                                width: 270,
                                label: 'Notas',
                                hint: 'Por favor insira notas',
                                validator: (value) {
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),

                          ///___________Buttons___________________________
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildButton(
                                label: lang.S.of(context).cancel,
                                color: Colors.red,
                                onTap: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 20),
                              _buildButton(
                                label: lang.S.of(context).saveAndPublish,
                                color: kGreenTextColor,
                                onTap: widget.payedSalary != null
                                    ? () async {
                                        if (formKey.currentState?.validate() ?? false) {
                                          final data = PaySalaryModel(
                                            id: widget.payedSalary!.id,
                                            designation: selectedEmployee?.designation ?? '',
                                            designationId: selectedEmployee?.designationId ?? 0,
                                            employeeName: selectedEmployee?.name ?? '',
                                            employmentId: selectedEmployee?.id ?? 0,
                                            month: selectedMonth ?? '',
                                            year: selectedYear ?? '',
                                            netSalary: selectedEmployee?.salary ?? 0,
                                            paySalary: num.tryParse(paySalaryController.text) ?? 0,
                                            payingDate: DateTime.now(),
                                            paymentType: selectedPaymentOption ?? '',
                                            note: notesController.text,
                                          );

                                          bool result = await SalaryRepository().updateSalary(salary: data);

                                          if (result) {
                                            ref.refresh(salaryProvider);
                                            Navigator.pop(context);
                                          }
                                        }
                                      }
                                    : () async {
                                        if (formKey.currentState?.validate() ?? false) {
                                          num id = DateTime.now().millisecondsSinceEpoch;

                                          bool result = await SalaryRepository().paySalary(
                                            salary: PaySalaryModel(
                                              id: id,
                                              designation: selectedEmployee?.designation ?? '',
                                              designationId: selectedEmployee?.designationId ?? 0,
                                              employeeName: selectedEmployee?.name ?? '',
                                              employmentId: selectedEmployee?.id ?? 0,
                                              month: selectedMonth ?? '',
                                              year: selectedYear ?? '',
                                              netSalary: selectedEmployee?.salary ?? 0,
                                              paySalary: num.tryParse(paySalaryController.text ?? '0') ?? 0,
                                              payingDate: DateTime.now(),
                                              paymentType: selectedPaymentOption ?? '',
                                              note: notesController.text,
                                            ),
                                          );

                                          if (result) {
                                            ref.refresh(salaryProvider);
                                            Navigator.pop(context);
                                          }
                                        }
                                      },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required double width,
    required String? Function(String?) validator,
  }) {
    return SizedBox(
      width: width,
      child: AppTextField(
        controller: controller,
        showCursor: true,
        cursorColor: kTitleColor,
        textFieldType: TextFieldType.NAME,
        decoration: kInputDecoration.copyWith(
          labelText: label,
          labelStyle: kTextStyle.copyWith(color: kTitleColor),
          hintText: hint,
          hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildButton({required String label, required Color color, required VoidCallback onTap}) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: color,
      ),
      width: 150,
      child: Center(
        child: Text(
          label,
          style: kTextStyle.copyWith(color: kWhite),
        ),
      ),
    ).onTap(onTap);
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required String label,
    required DateTime selectedDate,
    required Function(DateTime) onChanged,
  }) {
    return SizedBox(
      width: 270,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              label,
              style: kTextStyle.copyWith(color: kTitleColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );

              if (pickedDate != null) {
                onChanged(pickedDate);
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: kTextStyle.copyWith(color: kGreenTextColor),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.calendar_month,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
