import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Provider/sms_template_provider.dart';
import 'package:salespro_admin/Repository/sms_template_repo.dart';
import 'package:salespro_admin/Screen/User%20Role%20System/user_role_details.dart';
import 'package:salespro_admin/model/user_role_model.dart';
import '../../Provider/user_role_provider.dart';
import '../../const.dart';
import '../../model/whatsapp_marketing_sms_template_model.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';
import '../Widgets/noDataFound.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;

class WhatsappMarketingScreen extends StatefulWidget {
  const WhatsappMarketingScreen({Key? key}) : super(key: key);

  static const String route = '/whatsapp_marketing';

  @override
  State<WhatsappMarketingScreen> createState() =>
      _WhatsappMarketingScreenState();
}

class _WhatsappMarketingScreenState extends State<WhatsappMarketingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkCurrentUserAndRestartApp();
    // voidLink(context: context);
  }

  int selectedItem = 10;
  int itemCount = 10;
  ScrollController mainScroll = ScrollController();
  TextEditingController salesTemplateController = TextEditingController();
  TextEditingController salesReturnTemplateController = TextEditingController();
  TextEditingController quotationTemplateController = TextEditingController();
  TextEditingController purchaseTemplateController = TextEditingController();
  TextEditingController purchaseReturnTemplateController = TextEditingController();
  TextEditingController dueTemplateController = TextEditingController();
  TextEditingController bulkTemplateController = TextEditingController();

  // Sales list of strings
  List<String> salesFields = [
    '{{CUSTOMER_NAME}}',
    '{{CUSTOMER_ADDRESS}}',
    '{{CUSTOMER_GST}}',
    '{{INVOICE_NUMBER}}',
    '{{PURCHASE_DATE}}',
    '{{TOTAL_AMOUNT}}',
    '{{DUE_AMOUNT}}',
    '{{SERVICE_CHARGE}}',
    '{{VAT}}',
    '{{DISCOUNT_AMOUNT}}',
    '{{TOTAL_QUANTITY}}',
    '{{PAYMENT_TYPE}}',
  ];

// Purchase list of strings
  List<String> purchaseFields = [
    '{{CUSTOMER_NAME}}',
    '{{CUSTOMER_ADDRESS}}',
    '{{INVOICE_NUMBER}}',
    '{{PURCHASE_DATE}}',
    '{{TOTAL_AMOUNT}}',
    '{{DUE_AMOUNT}}',
    '{{DISCOUNT_AMOUNT}}',
    '{{PAYMENT_TYPE}}',
  ];

// Due list of strings
  List<String> dueFields = [
    '{{CUSTOMER_NAME}}',
    '{{CUSTOMER_ADDRESS}}',
    '{{CUSTOMER_GST}}',
    '{{INVOICE_NUMBER}}',
    '{{PURCHASE_DATE}}',
    '{{TOTAL_DUE}}',
    '{{DUE_AMOUNT_AFTER_PAY}}',
    '{{PAY_DUE_AMOUNT}}',
    '{{PAYMENT_TYPE}}',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: kDarkWhite,
          body: Scrollbar(
            controller: mainScroll,
            child: SingleChildScrollView(
              controller: mainScroll,
              scrollDirection: Axis.horizontal,
              child: Consumer(builder: (_, ref, watch) {
                final templates = ref.watch(smsTemplateProvider);
                return templates.when(data: (templates) {
                  salesTemplateController.text = templates.saleTemplate ?? "";
                  salesReturnTemplateController.text = templates.saleReturnTemplate ?? "";
                  quotationTemplateController.text = templates.quotationTemplate ?? "";
                  purchaseTemplateController.text = templates.purchaseTemplate ?? "";
                  purchaseReturnTemplateController.text = templates.purchaseReturnTemplate ?? "";
                  dueTemplateController.text = templates.dueTemplate ?? "";
                  bulkTemplateController.text = templates.bulkSmsTemplate ?? "";
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 240,
                        child: SideBarWidget(
                          index: 14,
                          isTab: false,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width < 1275
                            ? 1275 - 240
                            : MediaQuery.of(context).size.width - 240,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: kWhite,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: defaultBoxShadow(),
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "Whatsapp Marketing SMS Template",
                                                    style: boldTextStyle(
                                                        size: 20)),
                                                20.height,
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text("Sales Template:",
                                                          style:
                                                              secondaryTextStyle(
                                                                  size: 16)),
                                                    ),
                                                    10.width,
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: salesTemplateController,
                                                        maxLines: 5,
                                                        decoration:
                                                            InputDecoration(
                                                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                          hintText:
                                                              "Enter Sales Template",
                                                          hintStyle:
                                                              secondaryTextStyle(
                                                                  size: 16),
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                              enabledBorder: OutlineInputBorder(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      10)),
                                                              focusedBorder: OutlineInputBorder(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      10)),

                                                        ),
                                                      ),
                                                    ),
                                                    10.width,
                                                    Expanded(child: Column(
                                                      children: [
                                                        Text("Shortcodes", style: boldTextStyle(size: 16)),
                                                        10.height,
                                                        Wrap(
                                                          children: List.generate(salesFields.length, (index) {
                                                            return InkWell(
                                                              onTap: () {
                                                                salesTemplateController.text = salesTemplateController.text + salesFields[index];
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets.all(5),
                                                                margin: EdgeInsets.all(5),
                                                                decoration: BoxDecoration(
                                                                  color: deepSkyBlue,
                                                                  borderRadius: BorderRadius.circular(5),
                                                                ),
                                                                child: Text(salesFields[index], style: secondaryTextStyle(color: kWhite),),
                                                              ),
                                                            );
                                                          }),
                                                        ),
                                                      ],
                                                    )),
                                                  ],
                                                ),
                                                20.height,
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text("Sales Return Template:",
                                                          style:
                                                          secondaryTextStyle(
                                                              size: 16)),
                                                    ),
                                                    10.width,
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: salesReturnTemplateController,
                                                        maxLines: 5,
                                                        decoration:
                                                        InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                          hintText:
                                                          "Enter Sales Return Template",
                                                          hintStyle:
                                                          secondaryTextStyle(
                                                              size: 16),
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),
                                                          enabledBorder: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),
                                                          focusedBorder: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),

                                                        ),
                                                      ),
                                                    ),
                                                    10.width,
                                                    Expanded(child: Column(
                                                      children: [
                                                        Text("Shortcodes", style: boldTextStyle(size: 16)),
                                                        10.height,
                                                        Wrap(
                                                          children: List.generate(salesFields.length, (index) {
                                                            return InkWell(
                                                              onTap: () {
                                                                salesReturnTemplateController.text = salesReturnTemplateController.text + salesFields[index];
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets.all(5),
                                                                margin: EdgeInsets.all(5),
                                                                decoration: BoxDecoration(
                                                                  color: deepSkyBlue,
                                                                  borderRadius: BorderRadius.circular(5),
                                                                ),
                                                                child: Text(salesFields[index], style: secondaryTextStyle(color: kWhite),),
                                                              ),
                                                            );
                                                          }),
                                                        ),
                                                      ],
                                                    )),
                                                  ],
                                                ),
                                                20.height,
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text("Quotation Template:",
                                                          style:
                                                          secondaryTextStyle(
                                                              size: 16)),
                                                    ),
                                                    10.width,
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: quotationTemplateController,
                                                        maxLines: 5,
                                                        decoration:
                                                        InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                          hintText:
                                                          "Enter Quotation Template",
                                                          hintStyle:
                                                          secondaryTextStyle(
                                                              size: 16),
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),
                                                          enabledBorder: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),
                                                          focusedBorder: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),

                                                        ),
                                                      ),
                                                    ),
                                                    10.width,
                                                    Expanded(child: Column(
                                                      children: [
                                                        Text("Shortcodes", style: boldTextStyle(size: 16)),
                                                        10.height,
                                                        Wrap(
                                                          children: List.generate(salesFields.length, (index) {
                                                            return InkWell(
                                                              onTap: () {
                                                                quotationTemplateController.text = quotationTemplateController.text + salesFields[index];
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets.all(5),
                                                                margin: EdgeInsets.all(5),
                                                                decoration: BoxDecoration(
                                                                  color: deepSkyBlue,
                                                                  borderRadius: BorderRadius.circular(5),
                                                                ),
                                                                child: Text(salesFields[index], style: secondaryTextStyle(color: kWhite),),
                                                              ),
                                                            );
                                                          }),
                                                        ),
                                                      ],
                                                    )),
                                                  ],
                                                ),
                                                20.height,
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text("Purchase Template:",
                                                          style:
                                                          secondaryTextStyle(
                                                              size: 16)),
                                                    ),
                                                    10.width,
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: purchaseTemplateController,
                                                        maxLines: 5,
                                                        decoration:
                                                        InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                          hintText:
                                                          "Enter Purchase Template",
                                                          hintStyle:
                                                          secondaryTextStyle(
                                                              size: 16),
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),
                                                          enabledBorder: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),
                                                          focusedBorder: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),

                                                        ),
                                                      ),
                                                    ),
                                                    10.width,
                                                    Expanded(child: Column(
                                                      children: [
                                                        Text("Shortcodes", style: boldTextStyle(size: 16)),
                                                        10.height,
                                                        Wrap(
                                                          children: List.generate(purchaseFields.length, (index) {
                                                            return InkWell(
                                                              onTap: () {
                                                                purchaseTemplateController.text = purchaseTemplateController.text + purchaseFields[index];
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets.all(5),
                                                                margin: EdgeInsets.all(5),
                                                                decoration: BoxDecoration(
                                                                  color: deepSkyBlue,
                                                                  borderRadius: BorderRadius.circular(5),
                                                                ),
                                                                child: Text(salesFields[index], style: secondaryTextStyle(color: kWhite),),
                                                              ),
                                                            );
                                                          }),
                                                        ),
                                                      ],
                                                    )),
                                                  ],
                                                ),
                                                20.height,
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text("Purchase Return Template:",
                                                          style:
                                                          secondaryTextStyle(
                                                              size: 16)),
                                                    ),
                                                    10.width,
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: purchaseReturnTemplateController,
                                                        maxLines: 5,
                                                        decoration:
                                                        InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                          hintText:
                                                          "Enter Purchase Return Template",
                                                          hintStyle:
                                                          secondaryTextStyle(
                                                              size: 16),
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),
                                                          enabledBorder: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),
                                                          focusedBorder: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),

                                                        ),
                                                      ),
                                                    ),
                                                    10.width,
                                                    Expanded(child: Column(
                                                      children: [
                                                        Text("Shortcodes", style: boldTextStyle(size: 16)),
                                                        10.height,
                                                        Wrap(
                                                          children: List.generate(purchaseFields.length, (index) {
                                                            return InkWell(
                                                              onTap: () {
                                                                purchaseReturnTemplateController.text = purchaseReturnTemplateController.text + purchaseFields[index];
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets.all(5),
                                                                margin: EdgeInsets.all(5),
                                                                decoration: BoxDecoration(
                                                                  color: deepSkyBlue,
                                                                  borderRadius: BorderRadius.circular(5),
                                                                ),
                                                                child: Text(salesFields[index], style: secondaryTextStyle(color: kWhite),),
                                                              ),
                                                            );
                                                          }),
                                                        ),
                                                      ],
                                                    )),
                                                  ],
                                                ),
                                                20.height,
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text("Due Template:",
                                                          style:
                                                          secondaryTextStyle(
                                                              size: 16)),
                                                    ),
                                                    10.width,
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: dueTemplateController,
                                                        maxLines: 5,
                                                        decoration:
                                                        InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                          hintText:
                                                          "Enter Due Template",
                                                          hintStyle:
                                                          secondaryTextStyle(
                                                              size: 16),
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),
                                                          enabledBorder: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),
                                                          focusedBorder: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),

                                                        ),
                                                      ),
                                                    ),
                                                    10.width,
                                                    Expanded(child: Column(
                                                      children: [
                                                        Text("Shortcodes", style: boldTextStyle(size: 16)),
                                                        10.height,
                                                        Wrap(
                                                          children: List.generate(dueFields.length, (index) {
                                                            return InkWell(
                                                              onTap: () {
                                                                dueTemplateController.text = dueTemplateController.text + dueFields[index];
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets.all(5),
                                                                margin: EdgeInsets.all(5),
                                                                decoration: BoxDecoration(
                                                                  color: deepSkyBlue,
                                                                  borderRadius: BorderRadius.circular(5),
                                                                ),
                                                                child: Text(salesFields[index], style: secondaryTextStyle(color: kWhite),),
                                                              ),
                                                            );
                                                          }),
                                                        ),
                                                      ],
                                                    )),
                                                  ],
                                                ),
                                                20.height,
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text("Bulk Template:",
                                                          style:
                                                          secondaryTextStyle(
                                                              size: 16)),
                                                    ),
                                                    10.width,
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: bulkTemplateController,
                                                        maxLines: 5,
                                                        decoration:
                                                        InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                          hintText:
                                                          "Enter Bulk SMS Template",
                                                          hintStyle:
                                                          secondaryTextStyle(
                                                              size: 16),
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),
                                                          enabledBorder: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),
                                                          focusedBorder: OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),

                                                        ),
                                                      ),
                                                    ),
                                                    10.width,
                                                    Expanded(child: SizedBox()),
                                                  ],
                                                ),
                                                20.height,
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    10.width,
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        EasyLoading.show(status: 'Updating Template');
                                                        await SmsTemplateRepo().updateTemplate(WhatsappMarketingSmsTemplateModel(
                                                          saleTemplate: salesTemplateController.text,
                                                          purchaseTemplate: purchaseTemplateController.text,
                                                          purchaseReturnTemplate: purchaseReturnTemplateController.text,
                                                          saleReturnTemplate: salesReturnTemplateController.text,
                                                          quotationTemplate: quotationTemplateController.text,
                                                          dueTemplate: dueTemplateController.text,
                                                          bulkSmsTemplate: bulkTemplateController.text,
                                                        ));
                                                        EasyLoading.dismiss();
                                                      },
                                                      child: Text("Update Template"),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                  visible:
                                      MediaQuery.of(context).size.height != 0,
                                  child: const Footer()),
                            ],
                          ),
                        ),
                      )
                    ],
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
              }),
            ),
          )),
    );
  }
}
