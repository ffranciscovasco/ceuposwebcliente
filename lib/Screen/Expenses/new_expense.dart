// ignore_for_file: unused_result

import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Provider/all_expanse_provider.dart';
import 'package:salespro_admin/Provider/expense_category_proivder.dart';
import 'package:salespro_admin/model/expense_model.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../Provider/daily_transaction_provider.dart';
import '../../commas.dart';
import '../../const.dart';
import '../../model/daily_transaction_model.dart';
import '../../model/expense_category_model.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';
import 'expenses_list.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({Key? key}) : super(key: key);

  static const String route = '/expenseslist/newexpense';

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  bool saleButtonClicked = false;

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
    'Bank',
    'Card',
    'Mobile Payment',
    'Snacks',
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
      hint: const Text('Select expense category'),
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
    await FirebaseDatabase.instance.ref(await getUserID()).child('Expense Category').orderByKey().get().then((value) {
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

  String expenseAmount = '0';
  TextEditingController expanseForNameController = TextEditingController();
  TextEditingController expanseAmountController = TextEditingController();
  TextEditingController expanseNoteController = TextEditingController();
  TextEditingController expanseRefController = TextEditingController();
  ScrollController mainScroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final expenseCategory = ref.watch(expenseCategoryProvider);

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
                      index: 10,
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
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          lang.S.of(context).expense,
                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 21.0),
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        Text(
                                          lang.S.of(context).addUpdateExpenseList,
                                          style: kTextStyle.copyWith(color: kLitGreyColor),
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
                                                  labelText: lang.S.of(context).expenseDate,
                                                  labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                                  hintText: lang.S.of(context).enterExpenseDate,
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
                                                decoration: const InputDecoration(
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                      borderSide: BorderSide(color: kBorderColorTextField, width: 2),
                                                    ),
                                                    contentPadding: EdgeInsets.all(8.0),
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    labelText: 'Category'),
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
                                            controller: expanseForNameController,
                                            validator: (value) {
                                              if (value.isEmptyOrNull) {
                                                return 'Please Enter Name';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) {
                                              expanseForNameController.text = value!;
                                            },
                                            cursorColor: kTitleColor,
                                            decoration: kInputDecoration.copyWith(
                                              errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                                              labelText: lang.S.of(context).expenseFor,
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
                                                    child: DropdownButtonHideUnderline(child: getPaymentMethods())),
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
                                            controller: expanseAmountController,
                                            onChanged: (value) {
                                              expenseAmount = value.replaceAll(',', '');
                                              var formattedText = myFormat.format(int.parse(expenseAmount));
                                              expanseAmountController.value = expanseAmountController.value.copyWith(
                                                text: formattedText,
                                                selection: TextSelection.collapsed(offset: formattedText.length),
                                              );
                                            },
                                            validator: (value) {
                                              if (expenseAmount.isEmptyOrNull) {
                                                return 'please Inter Amount';
                                              } else if (double.tryParse(expenseAmount) == null) {
                                                return 'Enter a valid Amount';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) {
                                              expanseAmountController.text = value!;
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
                                            controller: expanseRefController,
                                            validator: (value) {
                                              return null;
                                            },
                                            onSaved: (value) {
                                              expanseRefController.text = value!;
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
                                        controller: expanseNoteController,
                                        validator: (value) {
                                          if (value == null) {
                                            return 'please Inter Amount';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          expanseNoteController.text = value!;
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
                                        ).onTap(saleButtonClicked
                                            ? () {}
                                            : () async {
                                                if (validateAndSave() && selectedCategories != null && selectedCategories!.isNotEmpty) {
                                                  ExpenseModel expense = ExpenseModel(
                                                    expenseDate: selectedDate.toString(),
                                                    category: selectedCategories.toString(),
                                                    account: '',
                                                    amount: expenseAmount,
                                                    expanseFor: expanseForNameController.text,
                                                    paymentType: selectedPaymentType,
                                                    referenceNo: expanseRefController.text,
                                                    note: expanseNoteController.text,
                                                  );
                                                  try {
                                                    setState(() {
                                                      saleButtonClicked = true;
                                                    });
                                                    EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                                                    final DatabaseReference productInformationRef = FirebaseDatabase.instance.ref().child(await getUserID()).child('Expense');
                                                    await productInformationRef.push().set(expense.toJson());
                                                    EasyLoading.showSuccess('Added Successfully', duration: const Duration(milliseconds: 500));

                                                    ///________daily_transactionModel_________________________________________________________________________

                                                    DailyTransactionModel dailyTransaction = DailyTransactionModel(
                                                      name: expense.expanseFor,
                                                      date: expense.expenseDate,
                                                      type: 'Expense',
                                                      total: expense.amount.toDouble(),
                                                      paymentIn: 0,
                                                      paymentOut: expense.amount.toDouble(),
                                                      remainingBalance: expense.amount.toDouble(),
                                                      id: expense.expenseDate,
                                                      expenseModel: expense,
                                                    );
                                                    postDailyTransaction(dailyTransactionModel: dailyTransaction);

                                                    ///____provider_refresh____________________________________________
                                                    ref.refresh(expenseProvider);
                                                    ref.refresh(dailyTransactionProvider);

                                                    Future.delayed(const Duration(milliseconds: 100), () {
                                                      // const Product().launch(context, isNewTask: true);
                                                      Navigator.pop(context);
                                                      Navigator.of(context).pushReplacementNamed(ExpensesList.route);
                                                    });
                                                  } catch (e) {
                                                    setState(() {
                                                      saleButtonClicked = false;
                                                    });
                                                    EasyLoading.dismiss();
                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                                  }
                                                } else {
                                                  EasyLoading.showInfo('Please select a category');
                                                }
                                              }),
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
