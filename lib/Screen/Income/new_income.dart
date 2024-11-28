import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Provider/daily_transaction_provider.dart';
import 'package:salespro_admin/model/income_modle.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../Provider/income_provider.dart';
import '../../commas.dart';
import '../../const.dart';
import '../../model/daily_transaction_model.dart';
import '../../model/expense_category_model.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';
import 'income_list.dart';

class NewIncome extends StatefulWidget {
  const NewIncome({Key? key}) : super(key: key);

  static const String route = '/IncomeList/NewIncome';

  @override
  State<NewIncome> createState() => _NewIncomeState();
}

class _NewIncomeState extends State<NewIncome> {
  bool saveButtonClicked = false;

  void showCategoryPopUp() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: SizedBox(
                width: 600,
                height: context.height() / 2.5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: const BoxDecoration(shape: BoxShape.rectangle),
                            child: const Icon(
                              FeatherIcons.plus,
                              color: kTitleColor,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            lang.S.of(context).addCategory,
                            style: kTextStyle.copyWith(color: kTitleColor, fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          const Icon(
                            FeatherIcons.x,
                            color: kTitleColor,
                            size: 50.0,
                          ).onTap(() {
                            finish(context);
                          })
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Divider(
                        thickness: 1.0,
                        color: kGreyTextColor.withOpacity(0.2),
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          Text(
                            lang.S.of(context).nam,
                            style: kTextStyle.copyWith(color: kTitleColor, fontSize: 18.0),
                          ),
                          const SizedBox(width: 50),
                          SizedBox(
                            width: 400,
                            child: Expanded(
                              child: AppTextField(
                                showCursor: true,
                                cursorColor: kTitleColor,
                                textFieldType: TextFieldType.NAME,
                                decoration: kInputDecoration.copyWith(
                                  hintText: lang.S.of(context).name,
                                  hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Divider(
                        thickness: 1.0,
                        color: kGreyTextColor.withOpacity(0.2),
                      ),
                      const SizedBox(height: 5.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: kRedTextColor),
                            child: Text(
                              lang.S.of(context).cancel,
                              style: kTextStyle.copyWith(color: kWhite),
                            ),
                          ).onTap(() {
                            finish(context);
                          }),
                          const SizedBox(
                            width: 5.0,
                          ),
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: kGreenTextColor),
                            child: Text(
                              lang.S.of(context).submit,
                              style: kTextStyle.copyWith(color: kWhite),
                            ),
                          ).onTap(() {
                            finish(context);
                          })
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  List<String> categories = [];
  List<String> paymentMethods = [
    'Cash',
  ];

  String? selectedCategories;
  String selectedPaymentType = 'Cash';

  DropdownButton<String> getCategories() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String des in categories) {
      var item = DropdownMenuItem(
        value: des,
        child: Text(des),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      hint: Text(
        'Selecione a categoria',
        style: kTextStyle.copyWith(color: kTitleColor),
      ),
      items: dropDownItems,
      value: selectedCategories,
      onChanged: (value) {
        setState(() {
          selectedCategories = value!;
        });
      },
    );
  }

  DropdownButton<String> getPaymentMethods() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String des in paymentMethods) {
      var item = DropdownMenuItem(
        value: des,
        child: Text(des),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      items: dropDownItems,
      value: selectedPaymentType,
      onChanged: (value) {
        setState(() {
          selectedPaymentType = value!;
        });
      },
    );
  }

  Future<void> category() async {
    final userId = await getUserID();

    await FirebaseDatabase.instance.ref(userId).child('Income Category').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = ExpenseCategoryModel.fromJson(jsonDecode(jsonEncode(element.value)));
        categories.add(data.categoryName);
      }
    });
    setState(() {});
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkCurrentUserAndRestartApp();
    category();
  }

  String incomeText = '0';
  TextEditingController incomeForNameController = TextEditingController();
  TextEditingController incomeAmountController = TextEditingController();
  TextEditingController incomeNoteController = TextEditingController();
  TextEditingController incomeRefController = TextEditingController();
  ScrollController mainScroll = ScrollController();

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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 240,
                    child: SideBarWidget(
                      index: 11,
                      isTab: false,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width < 1275 ? 1275 - 240 : MediaQuery.of(context).size.width - 240,
                    // width: context.width() < 1080 ? 1080 - 240 : MediaQuery.of(context).size.width - 240,
                    decoration: const BoxDecoration(color: kDarkWhite),
                    child: Column(
                      children: [
                        //_______________________________top_bar____________________________
                        const TopBar(),

                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height - 240,
                            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: kWhite),
                            child: Form(
                              key: formKey,
                              child: SingleChildScrollView(
                                controller: mainScroll,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          lang.S.of(context).income,
                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 21.0),
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        Text(
                                          lang.S.of(context).addUpdateIncomeList,
                                          style: kTextStyle.copyWith(color: kGreyTextColor),
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

                                    ///______date_&_category____________________________________
                                    Row(
                                      children: [
                                        ///__________date_picker________________________________
                                        Expanded(
                                          child: FormField(
                                            builder: (FormFieldState<dynamic> field) {
                                              return InputDecorator(
                                                decoration: InputDecoration(
                                                  suffixIcon: const Icon(FeatherIcons.calendar, color: kGreyTextColor),
                                                  enabledBorder: const OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                    borderSide: BorderSide(color: kBorderColorTextField, width: 2),
                                                  ),
                                                  contentPadding: const EdgeInsets.all(8.0),
                                                  labelText: lang.S.of(context).incomeDate,
                                                  labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                                  hintText: lang.S.of(context).enterIncomeDate,
                                                  hintStyle: kTextStyle.copyWith(color: kTitleColor),
                                                ),
                                                child: Text(
                                                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                                  style: kTextStyle.copyWith(color: kTitleColor),
                                                ),
                                              );
                                            },
                                          ).onTap(() => _selectDate(context)),
                                        ),
                                        const SizedBox(width: 20.0),

                                        ///_____category___________________________________________
                                        Expanded(
                                          child: FormField(
                                            builder: (FormFieldState<dynamic> field) {
                                              return InputDecorator(
                                                decoration: InputDecoration(
                                                    enabledBorder: const OutlineInputBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                      borderSide: BorderSide(color: kBorderColorTextField, width: 2),
                                                    ),
                                                    contentPadding: const EdgeInsets.all(8.0),
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    labelText: lang.S.of(context).category),
                                                child: Theme(
                                                    data: ThemeData(highlightColor: dropdownItemColor, focusColor: dropdownItemColor, hoverColor: dropdownItemColor),
                                                    child: DropdownButtonHideUnderline(child: getCategories())),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20.0),

                                    ///________payment Type_&_expanseFor_______________________________
                                    Row(
                                      children: [
                                        ///___________________Expanse for_______________________________
                                        Expanded(
                                          child: TextFormField(
                                            showCursor: true,
                                            controller: incomeForNameController,
                                            validator: (value) {
                                              if (value.isEmptyOrNull) {
                                                return 'Por favor insira o nome';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) {
                                              incomeForNameController.text = value!;
                                            },
                                            cursorColor: kTitleColor,
                                            decoration: kInputDecoration.copyWith(
                                              errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                                              labelText: lang.S.of(context).incomeFor,
                                              labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                              hintText: lang.S.of(context).enterName,
                                              hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 20),

                                        ///________PaymentType__________________________________
                                        Expanded(
                                          child: FormField(
                                            builder: (FormFieldState<dynamic> field) {
                                              return InputDecorator(
                                                decoration: InputDecoration(
                                                    enabledBorder: const OutlineInputBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                      borderSide: BorderSide(color: kBorderColorTextField, width: 2),
                                                    ),
                                                    contentPadding: const EdgeInsets.all(8.0),
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    labelText: lang.S.of(context).paymentType),
                                                child: Theme(
                                                  data: ThemeData(highlightColor: dropdownItemColor, focusColor: dropdownItemColor, hoverColor: dropdownItemColor),
                                                  child: DropdownButtonHideUnderline(
                                                    child: getPaymentMethods(),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20.0),

                                    ///_______amount_reference_number______________________________________
                                    Row(
                                      children: [
                                        ///_________________Amount_____________________________
                                        Expanded(
                                          child: TextFormField(
                                            showCursor: true,
                                            controller: incomeAmountController,
                                            onChanged: (value) {
                                              incomeText = value.replaceAll(',', '');
                                              var formattedText = myFormat.format(int.parse(incomeText));
                                              incomeAmountController.value = incomeAmountController.value.copyWith(
                                                text: formattedText,
                                                selection: TextSelection.collapsed(offset: formattedText.length),
                                              );
                                            },
                                            validator: (value) {
                                              if (incomeText.isEmptyOrNull) {
                                                return 'por favor valor entre';
                                              } else if (double.tryParse(incomeText) == null) {
                                                return 'Insira um valor válido';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) {
                                              incomeAmountController.text = value!;
                                            },
                                            cursorColor: kTitleColor,
                                            decoration: kInputDecoration.copyWith(
                                              errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                                              labelText: lang.S.of(context).amount,
                                              labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                              hintText: lang.S.of(context).enterAmount,
                                              hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 20),

                                        ///_______reference_________________________________
                                        Expanded(
                                          child: TextFormField(
                                            showCursor: true,
                                            controller: incomeRefController,
                                            validator: (value) {
                                              return null;
                                            },
                                            onSaved: (value) {
                                              incomeRefController.text = value!;
                                            },
                                            cursorColor: kTitleColor,
                                            decoration: kInputDecoration.copyWith(
                                              labelText: lang.S.of(context).referenceNumber,
                                              labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                              hintText: lang.S.of(context).enterReferenceNumber,
                                              hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    ///_________note____________________________________________________
                                    const SizedBox(height: 20.0),
                                    SizedBox(
                                      width: context.width() < 1080 ? 1080 - 240 : MediaQuery.of(context).size.width - 240,
                                      child: TextFormField(
                                        showCursor: true,
                                        controller: incomeNoteController,
                                        validator: (value) {
                                          if (value == null) {
                                            return 'por favor insira o valor';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          incomeNoteController.text = value!;
                                        },
                                        cursorColor: kTitleColor,
                                        decoration: kInputDecoration.copyWith(
                                          labelText: lang.S.of(context).note,
                                          labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                          hintText: lang.S.of(context).enterNote,
                                          hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                        ),
                                      ),
                                    ),

                                    ///___________buttons___________________________________________
                                    const SizedBox(height: 30.0),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ///_______cancel__________________________________________________

                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            width: 120,
                                            padding: const EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5.0),
                                              color: Colors.red,
                                            ),
                                            child: Center(
                                              child: Text(
                                                lang.S.of(context).cancel,
                                                style: kTextStyle.copyWith(color: kWhite),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),

                                        ///________save__________________________________________________
                                        Container(
                                          width: 120,
                                          padding: const EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5.0),
                                            color: kGreenTextColor,
                                          ),
                                          child: Center(
                                            child: Text(
                                              lang.S.of(context).saveAndPublish,
                                              style: kTextStyle.copyWith(color: kWhite),
                                            ),
                                          ),
                                        ).onTap(
                                          saveButtonClicked
                                              ? () async {}
                                              : () async {
                                                  if (validateAndSave() && selectedCategories != null && selectedCategories!.isNotEmpty) {
                                                    IncomeModel income = IncomeModel(
                                                      incomeDate: selectedDate.toString(),
                                                      category: selectedCategories.toString(),
                                                      account: '',
                                                      amount: incomeText,
                                                      incomeFor: incomeForNameController.text,
                                                      paymentType: selectedPaymentType,
                                                      referenceNo: incomeRefController.text,
                                                      note: incomeNoteController.text,
                                                    );
                                                    try {
                                                      setState(() {
                                                        saveButtonClicked = true;
                                                      });
                                                      EasyLoading.show(status: 'Processando...', dismissOnTap: false);
                                                      final DatabaseReference productInformationRef = FirebaseDatabase.instance.ref().child(await getUserID()).child('Income');
                                                      await productInformationRef.push().set(income.toJson());

                                                      ///________daily_transactionModel_________________________________________________________________________

                                                      DailyTransactionModel dailyTransaction = DailyTransactionModel(
                                                        name: income.incomeFor,
                                                        date: income.incomeDate,
                                                        type: 'Income',
                                                        total: income.amount.toDouble(),
                                                        paymentIn: income.amount.toDouble(),
                                                        paymentOut: 0,
                                                        remainingBalance: income.amount.toDouble(),
                                                        id: income.incomeDate,
                                                        incomeModel: income,
                                                      );
                                                      postDailyTransaction(dailyTransactionModel: dailyTransaction);

                                                      ///____provider_refresh____________________________________________
                                                      ref.refresh(incomeProvider);
                                                      ref.refresh(dailyTransactionProvider);
                                                      EasyLoading.showSuccess('Adicionado com sucesso', duration: const Duration(milliseconds: 500));

                                                      Future.delayed(const Duration(milliseconds: 100), () {
                                                        Navigator.pop(context);
                                                        Navigator.of(context).pushReplacementNamed(IncomeList.route);
                                                      });
                                                    } catch (e) {
                                                      setState(() {
                                                        saveButtonClicked = false;
                                                      });
                                                      EasyLoading.dismiss();
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                                    }
                                                  } else {
                                                    EasyLoading.showInfo('Selecione uma categoria');
                                                  }
                                                },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Footer(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
