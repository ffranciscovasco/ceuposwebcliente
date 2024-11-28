import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:salespro_admin/Screen/Reports/purchase_return_widget.dart';
import 'package:salespro_admin/commas.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Provider/transactions_provider.dart';
import 'package:salespro_admin/Screen/Reports/daily_transaction.dart';
import 'package:salespro_admin/Screen/Reports/purchase_report_widget.dart';
import 'package:salespro_admin/Screen/Reports/quotation_reports_wedget.dart';
import 'package:salespro_admin/Screen/Reports/seles_return_widget.dart';
import '../../PDF/print_pdf.dart';
import '../../PDF/sales_invoice_pdf.dart';
import '../../Provider/profile_provider.dart';
import '../../const.dart';
import '../../currency.dart';
import '../../model/sale_transaction_model.dart';
import '../Stock List/stock_list_screen.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';
import '../Widgets/noDataFound.dart';
import 'current_stock_widget.dart';
import 'due_reports_wedget.dart';
import 'loss_profit_report.dart';

class SaleReports extends StatefulWidget {
  const SaleReports({super.key});
  static const String route = '/reports';

  @override
  State<SaleReports> createState() => _SaleReportsState();
}

class _SaleReportsState extends State<SaleReports> {
  List<String> categoryList = [
    'Vendas',
    'Devolução de Vendas',
    'Compras',
    'Devolução de Compras',
    'Dividas/Pendentes',
    'Estoque Atual',
    'Transação Diária',
    'Histórico de Cotações',
    'Perdas/lucros',
  ];

  String selected = 'Vendas';

  String selectedMonth = 'Este mês';

  DateTime selectedDate = DateTime(DateTime.now().year, DateTime.now().month, 1);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  DateTime selected2ndDate = DateTime.now();

  Future<void> _selectedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: selected2ndDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selected2ndDate) {
      setState(() {
        selected2ndDate = picked;
      });
    }
  }

  List<String> month = ['Este mês', 'Mês passado', 'Ú 6 meses', 'Este ano', 'View All'];

  DropdownButton<String> getMonth() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String des in month) {
      var item = DropdownMenuItem(
        value: des,
        child: Text(des),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      items: dropDownItems,
      value: selectedMonth,
      onChanged: (value) {
        setState(() {
          selectedMonth = value!;
          switch (selectedMonth) {
            case 'Este mês':
              {
                var date = DateTime(DateTime.now().year, DateTime.now().month, 1).toString();

                selectedDate = DateTime.parse(date);
                selected2ndDate = DateTime.now();
              }
              break;
            case 'Mês passado':
              {
                selectedDate = DateTime(DateTime.now().year, DateTime.now().month - 1, 1);
                selected2ndDate = DateTime(DateTime.now().year, DateTime.now().month, 0);
              }
              break;
            case 'Ú 6 meses':
              {
                selectedDate = DateTime(DateTime.now().year, DateTime.now().month - 6, 1);
                selected2ndDate = DateTime.now();
              }
              break;
            case 'Este ano':
              {
                selectedDate = DateTime(DateTime.now().year, 1, 1);
                selected2ndDate = DateTime.now();
              }
              break;
            case 'Ver tudo':
              {
                selectedDate = DateTime(1900, 01, 01);
                selected2ndDate = DateTime.now();
              }
              break;
          }
        });
      },
    );
  }

  String searchItem = '';

  @override
  void initState() {
    super.initState();
    checkCurrentUserAndRestartApp();
  }

  double getTotalDue(List<SaleTransactionModel> transitionModel) {
    double total = 0.0;
    for (var element in transitionModel) {
      total += element.dueAmount!;
    }
    return total;
  }

  double calculateTotalSale(List<SaleTransactionModel> transitionModel) {
    double total = 0.0;
    for (var element in transitionModel) {
      total += element.totalAmount!;
    }
    return total;
  }

  ScrollController mainScroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkWhite,
      body: Scrollbar(
        controller: mainScroll,
        child: SingleChildScrollView(
          controller: mainScroll,
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 240,
                child: SideBarWidget(
                  index: 13,
                  isTab: false,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width < 1275 ? 1275 - 240 : MediaQuery.of(context).size.width - 240,
                // width: context.width() < 1080 ? 1080 - 240 : MediaQuery.of(context).size.width - 240,
                decoration: const BoxDecoration(color: kDarkWhite),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //_______________________________top_bar____________________________
                      const TopBar(),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Container(
                                    width: context.width(),
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        topRight: Radius.circular(10.0),
                                      ),
                                      color: kGreyTextColor.withOpacity(0.1),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lang.S.of(context).transactionReport,
                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0),
                                        ),
                                        color: kWhite),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ListView.builder(
                                            itemCount: categoryList.length,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemBuilder: (_, i) {
                                              return Container(
                                                padding: const EdgeInsets.all(5.0),
                                                decoration: BoxDecoration(
                                                  color: selected == categoryList[i] ? Colors.grey.shade100 : null,
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    categoryList[i],
                                                    style: kTextStyle.copyWith(color: kTitleColor),
                                                  ),
                                                ),
                                              ).onTap(() async {
                                                if (categoryList[i] == 'Estoque atual') {
                                                  if (await checkUserRolePermission(type: StockListScreen.route)) {
                                                    setState(() {
                                                      selected = categoryList[i];
                                                    });
                                                  }
                                                } else {
                                                  setState(() {
                                                    selected = categoryList[i];
                                                  });
                                                }
                                              });
                                            })
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20.0),
                            Consumer(builder: (_, ref, watch) {
                              AsyncValue<List<SaleTransactionModel>> transactionReport = ref.watch(transitionProvider);
                              return transactionReport.when(data: (transaction) {
                                List<SaleTransactionModel> reTransaction = [];
                                for (var element in transaction.reversed.toList()) {
                                  if ((element.invoiceNumber.toLowerCase().contains(searchItem.toLowerCase()) ||
                                          element.customerName.toLowerCase().contains(searchItem.toLowerCase())) &&
                                      (selectedDate.isBefore(DateTime.parse(element.purchaseDate)) || DateTime.parse(element.purchaseDate).isAtSameMomentAs(selectedDate)) &&
                                      (selected2ndDate.isAfter(DateTime.parse(element.purchaseDate)) || DateTime.parse(element.purchaseDate).isAtSameMomentAs(selected2ndDate))) {
                                    reTransaction.add(element);
                                  }
                                }
                                final profile = ref.watch(profileDetailsProvider);
                                return Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          color: kWhite,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ///____________day_filter________________________________________________________________
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 150,
                                                  child: FormField(
                                                    builder: (FormFieldState<dynamic> field) {
                                                      return InputDecorator(
                                                        decoration: const InputDecoration(
                                                          border: InputBorder.none,
                                                        ),
                                                        child: Theme(
                                                            data: ThemeData(highlightColor: dropdownItemColor, focusColor: dropdownItemColor, hoverColor: dropdownItemColor),
                                                            child: DropdownButtonHideUnderline(child: getMonth())),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 10.0),
                                                Container(
                                                    height: 30,
                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), border: Border.all(color: kGreyTextColor)),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 70,
                                                          height: 30,
                                                          decoration: const BoxDecoration(shape: BoxShape.rectangle, color: kGreyTextColor),
                                                          child: Center(
                                                            child: Text(
                                                              lang.S.of(context).between,
                                                              style: kTextStyle.copyWith(color: kWhite),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 10.0),
                                                        Text(
                                                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                                          style: kTextStyle.copyWith(color: kTitleColor),
                                                        ).onTap(() => _selectDate(context)),
                                                        const SizedBox(width: 10.0),
                                                        Text(
                                                          lang.S.of(context).to,
                                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                                        ),
                                                        const SizedBox(width: 10.0),
                                                        Text(
                                                          '${selected2ndDate.day}/${selected2ndDate.month}/${selected2ndDate.year}',
                                                          style: kTextStyle.copyWith(color: kTitleColor),
                                                        ).onTap(() => _selectedDate(context)),
                                                        const SizedBox(width: 10.0),
                                                      ],
                                                    )),
                                              ],
                                            ),

                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.only(left: 10.0, right: 20.0, top: 10.0, bottom: 10.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    color: const Color(0xFFCFF4E3),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        reTransaction.length.toString(),
                                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                                      ),
                                                      Text(
                                                        lang.S.of(context).totalSale,
                                                        style: kTextStyle.copyWith(color: kTitleColor),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 10.0),
                                                Container(
                                                  padding: const EdgeInsets.only(left: 10.0, right: 20.0, top: 10.0, bottom: 10.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    color: const Color(0xFFFEE7CB),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '${myFormat.format(double.tryParse(getTotalDue(reTransaction).toString()) ?? 0)} $currency',
                                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                                      ),
                                                      Text(
                                                        lang.S.of(context).unPaid,
                                                        style: kTextStyle.copyWith(color: kTitleColor),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 10.0),
                                                Container(
                                                  padding: const EdgeInsets.only(left: 10.0, right: 20.0, top: 10.0, bottom: 10.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    color: const Color(0xFFFED3D3),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '${myFormat.format(double.tryParse(calculateTotalSale(reTransaction).toString()) ?? 0)} $currency',
                                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                                      ),
                                                      Text(
                                                        lang.S.of(context).totalAmount,
                                                        style: kTextStyle.copyWith(color: kTitleColor),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20.0),
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
                                              children: [
                                                Text(
                                                  lang.S.of(context).saleTransaction,
                                                  style: kTextStyle.copyWith(color: kTitleColor, fontSize: 18.0, fontWeight: FontWeight.bold),
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
                                            Row(
                                              children: [
                                                Container(
                                                  height: 40.0,
                                                  width: 300,
                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), border: Border.all(color: kGreyTextColor.withOpacity(0.1))),
                                                  child: AppTextField(
                                                    showCursor: true,
                                                    cursorColor: kTitleColor,
                                                    textFieldType: TextFieldType.NAME,
                                                    decoration: kInputDecoration.copyWith(
                                                      contentPadding: const EdgeInsets.all(0.0),
                                                      hintText: (lang.S.of(context).search),
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
                                                              borderRadius: BorderRadius.circular(8.0),
                                                              color: kGreyTextColor.withOpacity(0.1),
                                                            ),
                                                            child: const Icon(
                                                              FeatherIcons.search,
                                                              color: kTitleColor,
                                                            )),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Icon(
                                                  MdiIcons.contentCopy,
                                                  color: kTitleColor,
                                                ),
                                                const SizedBox(width: 5.0),
                                                Icon(MdiIcons.microsoftExcel, color: kTitleColor),
                                                const SizedBox(width: 5.0),
                                                Icon(MdiIcons.fileDelimited, color: kTitleColor),
                                                const SizedBox(width: 5.0),
                                                Icon(MdiIcons.filePdfBox, color: kTitleColor),
                                                const SizedBox(width: 5.0),
                                                const Icon(FeatherIcons.printer, color: kTitleColor),
                                              ],
                                            ).visible(false),

                                            ///________sate_list_________________________________________________________
                                            reTransaction.isNotEmpty
                                                ? Column(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(15),
                                                        decoration: const BoxDecoration(color: kbgColor),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            const SizedBox(width: 35, child: Text('Nr')),
                                                            SizedBox(width: 82, child: Text(lang.S.of(context).date)),
                                                            SizedBox(width: 50, child: Text(lang.S.of(context).invoice)),
                                                            SizedBox(width: 100, child: Text(lang.S.of(context).partyName)),
                                                            SizedBox(width: 95, child: Text('Tipo de Pagamento')),
                                                            SizedBox(width: 70, child: Text(lang.S.of(context).amount)),
                                                            SizedBox(width: 60, child: Text('Divida')),
                                                            SizedBox(width: 50, child: Text(lang.S.of(context).status)),
                                                            const SizedBox(width: 30, child: Icon(FeatherIcons.settings)),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: (MediaQuery.of(context).size.height - 315).isNegative ? 0 : MediaQuery.of(context).size.height - 315,
                                                        child: ListView.builder(
                                                          shrinkWrap: true,
                                                          physics: const AlwaysScrollableScrollPhysics(),
                                                          itemCount: reTransaction.length,
                                                          itemBuilder: (BuildContext context, int index) {
                                                            return Column(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.all(15),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      ///______________S.L__________________________________________________
                                                                      SizedBox(
                                                                        width: 40,
                                                                        child: Text((index + 1).toString(), style: kTextStyle.copyWith(color: kGreyTextColor)),
                                                                      ),

                                                                      ///______________Date__________________________________________________
                                                                      SizedBox(
                                                                        width: 82,
                                                                        child: Text(
                                                                          reTransaction[index].purchaseDate.substring(0, 10),
                                                                          overflow: TextOverflow.ellipsis,
                                                                          maxLines: 2,
                                                                          style: kTextStyle.copyWith(color: kGreyTextColor, overflow: TextOverflow.ellipsis),
                                                                        ),
                                                                      ),

                                                                      ///____________Invoice_________________________________________________
                                                                      SizedBox(
                                                                        width: 50,
                                                                        child: Text(reTransaction[index].invoiceNumber,
                                                                            maxLines: 2, overflow: TextOverflow.ellipsis, style: kTextStyle.copyWith(color: kGreyTextColor)),
                                                                      ),

                                                                      ///______Party Name___________________________________________________________
                                                                      SizedBox(
                                                                        width: 100,
                                                                        child: Text(
                                                                          reTransaction[index].customerName,
                                                                          style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                          maxLines: 2,
                                                                          overflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      ),

                                                                      ///___________Party Type______________________________________________

                                                                      SizedBox(
                                                                        width: 95,
                                                                        child: Text(
                                                                          reTransaction[index].paymentType.toString(),
                                                                          style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                          maxLines: 2,
                                                                          overflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      ),

                                                                      ///___________Amount____________________________________________________
                                                                      SizedBox(
                                                                        width: 70,
                                                                        child: Text(
                                                                          myFormat.format(double.tryParse(reTransaction[index].totalAmount.toString()) ?? 0),
                                                                          style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                          maxLines: 2,
                                                                          overflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      ),

                                                                      ///___________Due____________________________________________________

                                                                      SizedBox(
                                                                        width: 60,
                                                                        child: Text(
                                                                          myFormat.format(double.tryParse(reTransaction[index].dueAmount.toString()) ?? 0),
                                                                          style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                          maxLines: 2,
                                                                          overflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      ),

                                                                      ///___________Due____________________________________________________

                                                                      SizedBox(
                                                                        width: 60,
                                                                        child: Text(
                                                                          reTransaction[index].isPaid! ? 'Pago' : "Devendo",
                                                                          style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                          maxLines: 2,
                                                                          overflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      ),

                                                                      ///_______________actions_________________________________________________
                                                                      SizedBox(
                                                                        width: 30,
                                                                        child: Theme(
                                                                          data: ThemeData(
                                                                              highlightColor: dropdownItemColor, focusColor: dropdownItemColor, hoverColor: dropdownItemColor),
                                                                          child: PopupMenuButton(
                                                                            surfaceTintColor: Colors.white,
                                                                            padding: EdgeInsets.zero,
                                                                            itemBuilder: (BuildContext bc) => [
                                                                              PopupMenuItem(
                                                                                child: GestureDetector(
                                                                                  onTap: () async {
                                                                                    await GeneratePdfAndPrint().printSaleInvoice(
                                                                                        personalInformationModel: profile.value!, saleTransactionModel: reTransaction[index]);
                                                                                    // await Printing.layoutPdf(
                                                                                    //   onLayout: (PdfPageFormat format) async =>
                                                                                    //   await GeneratePdfAndPrint().generateSaleDocument(personalInformation: profile.value!, transactions: reTransaction[index]),
                                                                                    // );
                                                                                    // SaleInvoice(
                                                                                    //   isPosScreen: false,
                                                                                    //   transitionModel: reTransaction[index],
                                                                                    //   personalInformationModel: profile.value!,
                                                                                    // ).launch(context);
                                                                                  },
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Icon(MdiIcons.printer, size: 18.0, color: kTitleColor),
                                                                                      const SizedBox(width: 4.0),
                                                                                      Text(
                                                                                        lang.S.of(context).print,
                                                                                        style: kTextStyle.copyWith(color: kTitleColor),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              PopupMenuItem(
                                                                                child: GestureDetector(
                                                                                  onTap: () async {
                                                                                    AnchorElement(
                                                                                        href:
                                                                                            "data:application/octet-stream;charset=utf-16le;base64,${base64Encode(await generateSaleDocument(personalInformation: profile.value!, transactions: reTransaction[index]))}")
                                                                                      ..setAttribute("download", "${invoiceFileName}_S-${reTransaction[index].invoiceNumber}.pdf")
                                                                                      ..click();
                                                                                  },
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Icon(MdiIcons.filePdfBox, size: 18.0, color: kTitleColor),
                                                                                      const SizedBox(width: 4.0),
                                                                                      Text(
                                                                                        lang.S.of(context).downloadPDF,
                                                                                        style: kTextStyle.copyWith(color: kTitleColor),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                            child: Center(
                                                                              child: Container(
                                                                                  height: 18,
                                                                                  width: 18,
                                                                                  alignment: Alignment.centerRight,
                                                                                  child: const Icon(
                                                                                    Icons.more_vert_sharp,
                                                                                    size: 18,
                                                                                  )),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: double.infinity,
                                                                  height: 1,
                                                                  color: kGreyTextColor.withOpacity(0.2),
                                                                )
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : noDataFoundImage(text: lang.S.of(context).noReportFound),
                                          ],
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
                            }).visible(selected == 'Vendas'),

                            ///____________Sales_return_report_________________________________________________
                            const SalesReturnWidget().visible(selected == 'Devolução de Vendas'),

                            ///____________Purchase_report_________________________________________________
                            const PurchaseReportWidget().visible(selected == 'Compras'),

                            ///____________Purchase_Return_report_________________________________________________
                            const PurchaseReturnWidget().visible(selected == 'Devolução de Compras'),

                            ///___________Due_report_______________________________________________________
                            const DueReportWidget().visible(selected == 'Dividas/Pendentes'),

                            ///__________Product_current_stocks_____________________________________________
                            const CurrentStockWidget().visible(selected == 'Estoque Atual'),

                            ///___________Due_report_________________________________________________________
                            const DailyTransaction().visible(selected == 'Transação Diária'),

                            ///___________Quotation_report___________________________________________________
                            const QuotationReportWidget().visible(selected == 'Histórico de Cotações'),

                            const LossProfitReport().visible(selected == 'Perdas/lucros'),
                          ],
                        ),
                      ),
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
  }
}
