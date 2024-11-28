import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/HRM/employees/provider/designation_provider.dart';
import 'package:salespro_admin/Screen/HRM/employees/repo/employee_repo.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../../const.dart';
import '../../Widgets/Constant Data/constant.dart';
import '../Designation/model/designation_model.dart';
import 'model/employee_model.dart';

class AddEmployeeScreen extends StatefulWidget {
  AddEmployeeScreen({super.key, required this.listOfEmployees, this.employeeModel, required this.ref, required this.designations});

  final List<EmployeeModel> listOfEmployees;
  EmployeeModel? employeeModel;
  final List<DesignationModel> designations;
  final WidgetRef ref;

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final List<String> genderList = ['Feminino', 'Masculino', 'Outro'];
  final List<String> typeList = ['Tempo total', 'Tempo parcial', 'Outro'];
  String? selectedGender;
  String? selectedType;
  DesignationModel? selectedDesignation;

  DateTime birthDate = DateTime.now();
  DateTime joiningDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    checkCurrentUserAndRestartApp();

    if (widget.employeeModel != null) {
      nameController.text = widget.employeeModel?.name ?? '';
      phoneNumberController.text = widget.employeeModel?.phoneNumber ?? '';
      emailController.text = widget.employeeModel?.email ?? '';
      addressController.text = widget.employeeModel?.address ?? '';
      salaryController.text = widget.employeeModel?.salary.toString() ?? '';
      birthDate = widget.employeeModel?.birthDate ?? DateTime.now();
      joiningDate = widget.employeeModel?.joiningDate ?? DateTime.now();
      selectedGender = widget.employeeModel?.gender;
      selectedType = widget.employeeModel?.employmentType;

      for (var element in widget.designations) {
        if (element.id == widget.employeeModel?.designationId) {
          setState(() {
            selectedDesignation = element;
          });
          return;
        }
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    addressController.dispose();
    salaryController.dispose();
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
                                'Adicionar funcionário',
                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 21.0),
                              ),
                              const Spacer(),
                              const Icon(FeatherIcons.x, color: kTitleColor, size: 30.0).onTap(() => Navigator.pop(context)),
                            ],
                          ),
                          const SizedBox(height: 20.0),

                          ///________Name and phone_________________________
                          Row(
                            children: [
                              _buildTextField(
                                controller: nameController,
                                label: 'Nome',
                                width: 270,
                                hint: 'Insira o nome do funcionário',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Insira o nome do funcionário';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(width: 20.0),
                              _buildTextField(
                                controller: phoneNumberController,
                                label: 'Número de telefone',
                                width: 270,
                                hint: 'Por favor insira o número de telefone',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Digite o número de telefone';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),

                          ///________Email_and_address_________________________
                          Row(
                            children: [
                              _buildTextField(
                                width: 270,
                                controller: emailController,
                                label: 'Email',
                                hint: 'Por favor insira o e-mail',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Digite o e-mail';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(width: 20.0),
                              _buildTextField(
                                width: 270,
                                controller: addressController,
                                label: 'Endereço',
                                hint: 'Por favor insira o endereço',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Insira o endereço';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),

                          ///________gender_and_type____________________________
                          Row(
                            children: [
                              SizedBox(
                                width: 270,
                                child: DropdownButtonFormField<String>(
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Gênero obrigatório';
                                    }
                                    return null;
                                  },
                                  decoration: kInputDecoration.copyWith(
                                    labelText: 'Gênero',
                                    labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                    hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                  ),
                                  value: selectedGender,
                                  hint: const Text(
                                    'Selecione o gênero',
                                    style: TextStyle(color: Colors.black54, fontSize: 16),
                                  ),
                                  items: genderList
                                      .map(
                                        (gender) => DropdownMenuItem(
                                          value: gender,
                                          child: Text(gender),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  dropdownColor: Colors.white,
                                  style: const TextStyle(color: Colors.black, fontSize: 16),
                                ),
                              ),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 270,
                                child: DropdownButtonFormField<String>(
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Tipo de funcionário obrigatório';
                                    }
                                    return null;
                                  },
                                  decoration: kInputDecoration.copyWith(
                                    labelText: 'Tipo de funcionário',
                                    labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                    hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                  ),
                                  value: selectedType,
                                  hint: const Text(
                                    'Tipo de funcionário',
                                    style: TextStyle(color: Colors.black54, fontSize: 16),
                                  ),
                                  items: typeList
                                      .map(
                                        (gender) => DropdownMenuItem(
                                          value: gender,
                                          child: Text(gender),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedType = value;
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

                          ///____________Salary_and_designation________________________
                          Row(
                            children: [
                              _buildTextField(
                                controller: salaryController,
                                width: 270,
                                label: 'Salário',
                                hint: 'Por favor insira o salário',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Insira o salário';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(width: 20),
                              // SizedBox(
                              //   width: 270,
                              //   child: Consumer(builder: (context, ref, __) {
                              //     final designation = ref.watch(designationProvider);
                              //     return designation.when(
                              //       data: (designations) {
                              //         return DropdownButtonFormField<DesignationModel>(
                              //           validator: (value) {
                              //             if (value == null) {
                              //               return 'Designations required';
                              //             }
                              //             return null;
                              //           },
                              //           decoration: kInputDecoration.copyWith(
                              //             labelText: 'Designations',
                              //             labelStyle: kTextStyle.copyWith(color: kTitleColor),
                              //             hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                              //           ),
                              //           value: selectedDesignation,
                              //           hint: const Text(
                              //             'Select Employee Designation',
                              //             style: TextStyle(color: Colors.black54, fontSize: 16),
                              //           ),
                              //           items: designations
                              //               .map(
                              //                 (items) => DropdownMenuItem(
                              //                   value: items,
                              //                   child: Text(items.designation),
                              //                 ),
                              //               )
                              //               .toList(),
                              //           onChanged: (value) {
                              //             setState(() {
                              //               selectedDesignation = value;
                              //             });
                              //           },
                              //           icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                              //           dropdownColor: Colors.white,
                              //           style: const TextStyle(color: Colors.black, fontSize: 16),
                              //         );
                              //       },
                              //       error: (error, stackTrace) {
                              //         return const Center(child: Text('Problem to getting data'));
                              //       },
                              //       loading: () {
                              //         return const Center(child: CircularProgressIndicator());
                              //       },
                              //     );
                              //   }),
                              // ),
                              SizedBox(
                                  width: 270,
                                  child: DropdownButtonFormField<DesignationModel>(
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Designações necessárias';
                                      }
                                      return null;
                                    },
                                    decoration: kInputDecoration.copyWith(
                                      labelText: 'Designações',
                                      labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                      hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                    ),
                                    value: selectedDesignation,
                                    hint: const Text(
                                      'Selecione a designação',
                                      style: TextStyle(color: Colors.black54, fontSize: 16),
                                    ),
                                    items: widget.designations!
                                        .map(
                                          (items) => DropdownMenuItem(
                                            value: items,
                                            child: Text(items.designation),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedDesignation = value;
                                      });
                                    },
                                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                    dropdownColor: Colors.white,
                                    style: const TextStyle(color: Colors.black, fontSize: 16),
                                  )),
                            ],
                          ),
                          const SizedBox(height: 20.0),

                          ///____________dates________________________
                          Row(
                            children: [
                              _buildDatePickerField(
                                context: context,
                                label: 'Data de nascimento',
                                selectedDate: birthDate,
                                onChanged: (value) => setState(() => birthDate = value),
                              ),
                              const SizedBox(width: 20.0),
                              Row(
                                children: [
                                  _buildDatePickerField(
                                    context: context,
                                    label: 'Data de adesão',
                                    selectedDate: joiningDate,
                                    onChanged: (value) => setState(() => joiningDate = value),
                                  ),
                                ],
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
                                onTap: widget.employeeModel != null
                                    ? () async {
                                        if (formKey.currentState?.validate() ?? false) {
                                          EmployeeModel data = EmployeeModel(
                                            id: widget.employeeModel!.id,
                                            name: nameController.text,
                                            phoneNumber: phoneNumberController.text,
                                            email: emailController.text,
                                            address: addressController.text,
                                            gender: selectedGender ?? '',
                                            employmentType: selectedType ?? '',
                                            designationId: selectedDesignation!.id,
                                            designation: selectedDesignation!.designation,
                                            birthDate: birthDate,
                                            joiningDate: joiningDate,
                                            salary: double.parse(salaryController.text),

                                          );

                                          bool result = await EmployeeRepository().updateEmployee(employee: data);

                                          if (result) {
                                            ref.refresh(employeeProvider);
                                            Navigator.pop(context);
                                          }
                                        }
                                      }
                                    : () async {
                                        if (formKey.currentState?.validate() ?? false) {
                                          num id = DateTime.now().millisecondsSinceEpoch;

                                          bool result = await EmployeeRepository().addEmployee(
                                            employee: EmployeeModel(
                                              id: id,
                                              name: nameController.text.trim(),
                                              phoneNumber: phoneNumberController.text.trim(),
                                              email: emailController.text.trim(),
                                              address: addressController.text.trim(),
                                              salary: double.parse(salaryController.text.trim()),
                                              birthDate: birthDate,
                                              joiningDate: joiningDate,
                                              gender: selectedGender!,
                                              employmentType: selectedType!,
                                              designation: selectedDesignation!.designation,
                                              designationId: selectedDesignation!.id,
                                            ),
                                          );

                                          if (result) {
                                            ref.refresh(employeeProvider);
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
