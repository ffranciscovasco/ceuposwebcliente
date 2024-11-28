import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/HRM/Designation/provider/designation_provider.dart';
import 'package:salespro_admin/Screen/HRM/Designation/repo/designation_repo.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../../const.dart';
import '../../Widgets/Constant Data/constant.dart';
import 'model/designation_model.dart';

class AddDesignationScreen extends StatefulWidget {
  AddDesignationScreen({super.key, required this.listOfIncomeCategory, this.designationModel});

  final List<DesignationModel> listOfIncomeCategory;
  DesignationModel? designationModel;

  @override
  State<AddDesignationScreen> createState() => _AddDesignationScreenState();
}

class _AddDesignationScreenState extends State<AddDesignationScreen> {
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    checkCurrentUserAndRestartApp();

    if (widget.designationModel != null) {
      _designationController.text = widget.designationModel?.designation ?? '';
      _descriptionController.text = widget.designationModel?.designationDescription ?? '';
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _designationController.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> names = widget.listOfIncomeCategory.map((element) => element.designation.removeAllWhiteSpace().toLowerCase()).toList();

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
                key: _formKey,
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
                                'Adicionar designação',
                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 21.0),
                              ),
                              const Spacer(),
                              const Icon(FeatherIcons.x, color: kTitleColor, size: 30.0).onTap(() => Navigator.pop(context)),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          _buildTextField(
                            controller: _designationController,
                            label: 'Designação',
                            hint: 'Por favor insira a designação',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Insira o nome da designação';
                              }
                              if (widget.designationModel != null
                                  ? (names.contains(value.removeAllWhiteSpace().toLowerCase()) && value.removeAllWhiteSpace().toLowerCase() != widget.designationModel!.designation)
                                  : (names.contains(value.removeAllWhiteSpace().toLowerCase()))) {
                                return 'O nome da designação já existe';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20.0),
                          _buildTextField(
                            controller: _descriptionController,
                            label: lang.S.of(context).description,
                            hint: lang.S.of(context).addDescription,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Insira a descrição';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20.0),
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
                                onTap: widget.designationModel != null
                                    ? () async {
                                        if (_formKey.currentState?.validate() ?? false) {
                                          widget.designationModel!.designation = _designationController.text;
                                          widget.designationModel!.designationDescription = _descriptionController.text;

                                          bool result = await DesignationRepository().updateDesignation(designation: widget.designationModel!);

                                          if (result) {
                                            ref.refresh(designationProvider);
                                            Navigator.pop(context);
                                          }
                                          ;
                                        }
                                      }
                                    : () async {
                                        if (_formKey.currentState?.validate() ?? false) {
                                          num id = DateTime.now().millisecondsSinceEpoch;

                                          bool result = await DesignationRepository().addDesignation(
                                            designation: DesignationModel(
                                                id: id, designation: _designationController.text.trim(), designationDescription: _descriptionController.text.trim()),
                                          );

                                          if (result) {
                                            ref.refresh(designationProvider);
                                            Navigator.pop(context);
                                          }
                                          ;
                                        }
                                      },
                              ),
                            ],
                          )
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
    required String? Function(String?) validator,
  }) {
    return SizedBox(
      width: 580,
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
}
