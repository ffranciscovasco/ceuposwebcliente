import 'dart:convert';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/tax%20rates/tax_model.dart';
import '../../const.dart';
import '../Widgets/Constant Data/constant.dart';

class EditGroupTaxPopUP extends StatefulWidget {
  const EditGroupTaxPopUP({super.key, required this.listOfGroupTax, required this.groupTaxModel});

  final List<GroupTaxModel> listOfGroupTax;
  final GroupTaxModel groupTaxModel;

  @override
  State<EditGroupTaxPopUP> createState() => _EditGroupTaxPopUPState();
}

class _EditGroupTaxPopUPState extends State<EditGroupTaxPopUP> {
  String name = '';
  num rate = 0;
  bool isListVisible = false;

  List<TaxModel> subTaxList = [];

  num calculateTotalRate(List<TaxModel> subTaxList) {
    rate = 0.0;
    for (var taxModel in subTaxList) {
      rate += taxModel.taxRate!;
    }
    return rate;
  }

  String taxKey = '';

  void getTaxKey() async {
    final userId = await getUserID();
    await FirebaseDatabase.instance.ref(userId).child('Group Tax List').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['name'].toString() == widget.groupTaxModel.name) {
          taxKey = element.key.toString();
        }
      }
    });
  }

  late GroupTaxModel newGroupTaxModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    name = widget.groupTaxModel.name;
    rate = widget.groupTaxModel.taxRate;
    getTaxKey();
    newGroupTaxModel = widget.groupTaxModel;
  }

  int i = 0;
  @override
  Widget build(BuildContext context) {
    List<String> names = [];
    for (var element in widget.listOfGroupTax) {
      names.add(element.name.removeAllWhiteSpace().toLowerCase());
    }
    return Consumer(
      builder: (_, ref, watch) {
        final tax = ref.watch(taxProvider);
        return tax.when(data: (taxList) {
          if (i == 0) {
            for (var tex in widget.groupTaxModel.subTaxes!) {
              TaxModel newTex = taxList.firstWhere((element) => element.id == tex.id);
              subTaxList.add(newTex);
            }
          }
          i++;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //___________________________________Tax Rates______________________________
                Row(
                  children: [
                    Text(
                      'Adicionar nova taxa do tipo único/múltiplo',
                      style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),
                const SizedBox(height: 10.0),
                Text('Nome*', style: kTextStyle.copyWith(color: kTitleColor)),
                const SizedBox(height: 8.0),
                TextFormField(
                  initialValue: name,
                  onChanged: (value) {
                    name = value;
                  },
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 8, right: 8.0),
                    border: OutlineInputBorder(),
                    hintText: 'Digite o nome',
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Sub-Taxas*',
                  style: kTextStyle.copyWith(color: kTitleColor),
                ),
                const SizedBox(height: 8.0),

                //_______________________________________________Tax_List______________________
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: Colors.transparent, border: Border.all(color: kBorderColorTextField)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      subTaxList.isNotEmpty
                          ? Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Wrap(
                                  children: List.generate(
                                    subTaxList.length,
                                    (index) {
                                      final category = subTaxList[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 5.0),
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: kMainColor),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                                padding: EdgeInsets.zero,
                                                onPressed: () {
                                                  setState(() {
                                                    // selectedCategories.removeAt(index);
                                                    subTaxList.removeAt(index);
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: kWhite,
                                                  size: 16,
                                                ),
                                              ),
                                              Text(
                                                category.name,
                                                style: kTextStyle.copyWith(color: kWhite),
                                              ),
                                              const SizedBox(width: 8)
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              'Nenhuma sub-taxa selecionada',
                              style: kTextStyle.copyWith(color: kTitleColor),
                            ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isListVisible = !isListVisible; // Toggle the flag
                          });
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: kGreyTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                //_______________________________________________Selected_Tax_List_____________
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: AnimatedContainer(
                    decoration: const BoxDecoration(color: kWhite, boxShadow: [BoxShadow(color: kDarkWhite, blurRadius: 4.0, offset: Offset(1, -1), spreadRadius: 2)]),
                    duration: const Duration(milliseconds: 300),
                    height: isListVisible ? MediaQuery.of(context).size.height * 0.5 : 0,
                    child: SingleChildScrollView(
                      physics: ScrollPhysics(),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: taxList.length,
                        itemBuilder: (context, index) {
                          final category = taxList[index];
                          return Column(
                            children: [
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                checkboxShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                                checkColor: kWhite,
                                activeColor: kMainColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                                fillColor: MaterialStateProperty.all(subTaxList.contains(category) ? kMainColor : Colors.transparent),
                                visualDensity: const VisualDensity(horizontal: -4),
                                side: const BorderSide(color: kBorderColorTextField),
                                title: Text(category.name.toString()),
                                value: subTaxList.contains(category),
                                onChanged: (isChecked) {
                                  setState(() {
                                    if (isChecked!) {
                                      if (!subTaxList.contains(category)) {
                                        subTaxList.add(category); // Add only the TaxModel instance
                                      }
                                    } else {
                                      subTaxList.remove(category);
                                    }
                                  });
                                },
                              ),
                              const Divider(
                                color: kBorderColorTextField,
                                height: 0.0,
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25.0),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 45.0,
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(left: 2, right: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        backgroundColor: kMainColor,
                        elevation: 1.0,
                        foregroundColor: kGreyTextColor.withOpacity(0.1),
                        shadowColor: kMainColor,
                        animationDuration: const Duration(milliseconds: 300),
                        textStyle: const TextStyle(color: Colors.white, fontFamily: 'Display', fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        num totalRate = calculateTotalRate(subTaxList);
                        GroupTaxModel groupTax = GroupTaxModel(name: name, taxRate: totalRate, id: widget.groupTaxModel.id.toString(), subTaxes: subTaxList);
                        if (name != '' && name == widget.groupTaxModel.name ? true : !names.contains(name.toLowerCase().removeAllWhiteSpace())) {
                          try {
                            EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                            final DatabaseReference productInformationRef = FirebaseDatabase.instance.ref().child(await getUserID()).child('Group Tax List').child(taxKey);
                            await productInformationRef.set(groupTax.toJson());
                            EasyLoading.showSuccess('Adicionado com sucesso', duration: const Duration(milliseconds: 500));
                            ref.refresh(groupTaxProvider);

                            Future.delayed(const Duration(milliseconds: 100)).then((value) => Navigator.pop(context));
                          } catch (e) {
                            EasyLoading.dismiss();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        } else {
                          EasyLoading.showError(name == '' ? 'Digite o nome' : 'Já existe');
                        }
                      },
                      child: Text(
                        'Salvar',
                        style: kTextStyle.copyWith(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
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
