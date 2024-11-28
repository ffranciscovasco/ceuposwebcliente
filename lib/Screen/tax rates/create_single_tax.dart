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

//____________________________________________________AddSingleTax_______________________
class CreateSingleTaxPopUp extends StatefulWidget {
  const CreateSingleTaxPopUp({super.key, required this.listOfTax});

  final List<TaxModel> listOfTax;

  @override
  State<CreateSingleTaxPopUp> createState() => _CreateSingleTaxPopUpState();
}

class _CreateSingleTaxPopUpState extends State<CreateSingleTaxPopUp> {
  String name = '';
  num rate = 0;
  String id = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString();

  @override
  Widget build(BuildContext context) {
    List<String> names = [];
    for (var element in widget.listOfTax) {
      names.add(element.name.removeAllWhiteSpace().toLowerCase());
    }
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //___________________________________Tax Rates______________________________
            Row(
              children: [
                Text(
                  'Adicionar nova Taxa',
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
            const SizedBox(height: 20.0),
            Text('Nome*', style: kTextStyle.copyWith(color: kTitleColor)),
            const SizedBox(height: 8.0),
            TextFormField(
              onChanged: (value) {
                name = value;
              },
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.only(left: 8, right: 8.0),
                border: OutlineInputBorder(),
                hintText: 'Digite o nome',
              ),
              onSaved: (value) {},
            ),
            const SizedBox(height: 20.0),
            Text(
              '% da Taxa',
              style: kTextStyle.copyWith(color: kTitleColor),
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              onChanged: (value) {
                rate = double.parse(value);
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.only(left: 8, right: 8.0),
                border: OutlineInputBorder(),
                hintText: 'Insira a % da taxa',
              ),
              onSaved: (value) {},
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
                    if (name != '' && !names.contains(name.toLowerCase().removeAllWhiteSpace())) {
                      TaxModel tax = TaxModel(name: name, taxRate: rate, id: id.toString());
                      try {
                        EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                        final DatabaseReference productInformationRef = FirebaseDatabase.instance.ref().child(await getUserID()).child('Tax List');
                        await productInformationRef.push().set(tax.toJson());
                        EasyLoading.showSuccess('Adicionado com sucesso', duration: const Duration(milliseconds: 500));

                        ///____provider_refresh____________________________________________
                        ref.refresh(taxProvider);

                        Future.delayed(const Duration(milliseconds: 100), () {
                          Navigator.pop(context);
                        });
                      } catch (e) {
                        EasyLoading.dismiss();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    } else if (names.contains(name.toLowerCase().removeAllWhiteSpace())) {
                      EasyLoading.showError('Já existe');
                    } else {
                      EasyLoading.showError('Digite o nome');
                    }
                  },
                  child: Text(
                    'Salvar',
                    style: kTextStyle.copyWith(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

//____________________________________________________EditSingleTax_______________________

class EditSingleTaxPopUp extends StatefulWidget {
  const EditSingleTaxPopUp({
    super.key,
    required this.taxList,
    required this.taxModel,
    required this.groupTaxList,
  });

  final List<TaxModel> taxList;
  final List<GroupTaxModel> groupTaxList;
  final TaxModel taxModel;

  @override
  State<EditSingleTaxPopUp> createState() => _EditSingleTaxTaxState();
}

class _EditSingleTaxTaxState extends State<EditSingleTaxPopUp> {
  String name = '';
  num rate = 0;
  String taxKey = '';

  void getTaxKey() async {
    final userId = await getUserID();
    await FirebaseDatabase.instance.ref(userId).child('Tax List').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['name'].toString() == widget.taxModel.name) {
          taxKey = element.key.toString();
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    name = widget.taxModel.name;
    rate = widget.taxModel.taxRate;
    getTaxKey();
  }

  @override
  Widget build(BuildContext context) {
    List<String> names = [];
    for (var element in widget.taxList) {
      names.add(element.name.removeAllWhiteSpace().toLowerCase());
    }
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final groupTax = ref.watch(groupTaxProvider);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //___________________________________Tax Rates______________________________
            Row(
              children: [
                Text(
                  'Editar',
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
            const SizedBox(height: 20.0),
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
              onSaved: (value) {},
            ),
            const SizedBox(height: 20.0),
            Text(
              '% da Taxa',
              style: kTextStyle.copyWith(color: kTitleColor),
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              initialValue: rate.toString(),
              onChanged: (value) {
                rate = double.parse(value);
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.only(left: 8, right: 8.0),
                border: OutlineInputBorder(),
                hintText: 'Insira a % da taxa',
              ),
              onSaved: (value) {},
            ),
            const SizedBox(height: 25),
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
                  onPressed: () {
                    TaxModel tax = TaxModel(taxRate: rate, id: widget.taxModel.id, name: name);
                    if (name != '' && name == widget.taxModel.name ? true : !names.contains(name.toLowerCase().removeAllWhiteSpace())) {
                      setState(() async {
                        try {
                          EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                          final DatabaseReference taxInfoRef = FirebaseDatabase.instance.ref().child(await getUserID()).child('Tax List').child(taxKey);
                          await taxInfoRef.set(tax.toJson());
                          EasyLoading.showSuccess('Editado com sucesso', duration: const Duration(milliseconds: 500));

                          ///____provider_refresh____________________________________________
                          ref.refresh(taxProvider);
                          ref.refresh(groupTaxProvider);
                          Future.delayed(const Duration(milliseconds: 100), () {
                            Navigator.pop(context);
                          });
                        } catch (e) {
                          EasyLoading.dismiss();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      });
                    } else if (names.contains(name.toLowerCase().removeAllWhiteSpace())) {
                      EasyLoading.showError('O nome já existe');
                    } else {
                      EasyLoading.showError('O nome não pode ficar vazio');
                    }
                  },
                  child: Text(
                    'Atualizar',
                    style: kTextStyle.copyWith(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

//____________________________________________________EditSingleTax_______________________
