import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:date_time_format/date_time_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:salespro_admin/PDF/purchase_invoice_pdf.dart';
import 'package:salespro_admin/PDF/purchase_return_invoice_pdf.dart';
import 'package:salespro_admin/PDF/sales_invoice_pdf.dart';
import 'package:salespro_admin/PDF/sales_return_pdf.dart';
import 'package:salespro_admin/Screen/Ledger%20Screen/ledger_screen.dart';
import 'package:salespro_admin/commas.dart';
import 'package:salespro_admin/currency.dart';
import 'package:salespro_admin/model/personal_information_model.dart';
import '../Screen/Inventory Sales/inventory_sales.dart';
import '../Screen/POS Sale/pos_sale.dart';
import '../Screen/Purchase/purchase.dart';
import '../const.dart';
import '../model/customer_model.dart';
import '../model/due_transaction_model.dart';
import '../model/purchase_transation_model.dart';
import '../model/sale_transaction_model.dart';

class GeneratePdfAndPrint {
  Future<void> uploadPdfToFirebase(Uint8List pdfData, String fileType, String invoiceNumber) async {
    // Get a reference to the Firebase Storage bucket
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('$fileType/invoice-$invoiceNumber.pdf');

    // Upload the PDF file
    try {
      UploadTask uploadTask = ref.putData(pdfData, SettableMetadata(contentType: 'application/pdf'));
      await uploadTask.whenComplete(() {
        print('PDF uploaded successfully!');
        //Print download url
        ref.getDownloadURL().then((value) {
          print('PDF Download URL: $value');
        });
      });
    } catch (e) {
      print('Error uploading PDF: $e');
    }
  }

  Future<void> printSaleInvoice(
      {required PersonalInformationModel personalInformationModel, required SaleTransactionModel saleTransactionModel, BuildContext? context, bool? fromInventorySale}) async {
    EasyLoading.show(status: 'Generating PDF...', dismissOnTap: true);
    var pdfData = await generateSaleDocument(personalInformation: personalInformationModel, transactions: saleTransactionModel);
    //Convert unint8List to pdf and upload in to firebase storage
    await uploadPdfToFirebase(pdfData, 'sale', saleTransactionModel.invoiceNumber);
    await Printing.layoutPdf(
      dynamicLayout: true,
      onLayout: (PdfPageFormat format) async => pdfData,
    );
    EasyLoading.dismiss();
    Future.delayed(const Duration(milliseconds: 200), () {
      ((fromInventorySale ?? false) && context != null) ? Navigator.pushReplacementNamed(context, InventorySales.route) : Navigator.pop(context!, true);
    });
  }

  Future<void> printSaleReturnInvoice(
      {required PersonalInformationModel personalInformationModel, required SaleTransactionModel saleTransactionModel, BuildContext? context, bool? fromInventorySale}) async {
    EasyLoading.show(status: 'Generating PDF...', dismissOnTap: true);
    var pdfData = await generateSaleReturnDocument(personalInformation: personalInformationModel, transactions: saleTransactionModel);
    await uploadPdfToFirebase(pdfData, 'sale-return', saleTransactionModel.invoiceNumber);
    EasyLoading.dismiss();
    await Printing.layoutPdf(
      dynamicLayout: true,
      onLayout: (PdfPageFormat format) async => pdfData,
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      ((fromInventorySale ?? false) && context != null) ? const InventorySales().launch(context, isNewTask: true) : const PosSale().launch(context!, isNewTask: true);
    });
  }

  Future<void> printQuotationInvoice(
      {required PersonalInformationModel personalInformationModel, required SaleTransactionModel saleTransactionModel, BuildContext? context, bool? isFromInventorySale}) async {
    EasyLoading.show(status: 'Generating PDF...', dismissOnTap: true);
    var pdfData = await GeneratePdfAndPrint().generateQuotationDocument(personalInformation: personalInformationModel, transactions: saleTransactionModel);
    await uploadPdfToFirebase(pdfData, 'quotation', saleTransactionModel.invoiceNumber);
    EasyLoading.dismiss();
    await Printing.layoutPdf(
      dynamicLayout: true,
      onLayout: (PdfPageFormat format) async => pdfData,
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      context != null
          ? (isFromInventorySale ?? false)
              ? Navigator.pushReplacementNamed(context, InventorySales.route)
              : Navigator.pushReplacementNamed(context, PosSale.route)
          : null;
    });
  }

  Future<void> printPurchaseInvoice(
      {required PersonalInformationModel personalInformationModel, required PurchaseTransactionModel purchaseTransactionModel, BuildContext? context}) async {
    EasyLoading.show(status: 'Generating PDF...', dismissOnTap: true);
    var pdfData = await generatePurchaseDocument(personalInformation: personalInformationModel, transactions: purchaseTransactionModel);
    await uploadPdfToFirebase(pdfData, 'purchase', purchaseTransactionModel.invoiceNumber);
    EasyLoading.dismiss();
    await Printing.layoutPdf(
      dynamicLayout: true,
      onLayout: (PdfPageFormat format) async => pdfData,
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      context != null ?Navigator.pop(context,true) : null;
    });
  }

  Future<void> printPurchaseReturnInvoice(
      {required PersonalInformationModel personalInformationModel, required PurchaseTransactionModel purchaseTransactionModel, BuildContext? context}) async {
    EasyLoading.show(status: 'Generating PDF...', dismissOnTap: true);
    var pdfData = await generatePurchaseReturnDocument(personalInformation: personalInformationModel, transactions: purchaseTransactionModel);
    await uploadPdfToFirebase(pdfData, 'purchase-return', purchaseTransactionModel.invoiceNumber);
    EasyLoading.dismiss();
    await Printing.layoutPdf(
      dynamicLayout: true,
      onLayout: (PdfPageFormat format) async => pdfData,
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      context != null ? const Purchase().launch(context, isNewTask: true) : null;
    });
  }

  Future<void> printDueInvoice({required PersonalInformationModel personalInformationModel, required DueTransactionModel dueTransactionModel, BuildContext? context}) async {
    EasyLoading.show(status: 'Generating PDF...', dismissOnTap: true);
    var pdfData = await GeneratePdfAndPrint().generateDueDocument(personalInformation: personalInformationModel, transactions: dueTransactionModel);
    await uploadPdfToFirebase(pdfData, 'due', dueTransactionModel.invoiceNumber);
    EasyLoading.dismiss();
    await Printing.layoutPdf(
      dynamicLayout: true,
      onLayout: (PdfPageFormat format) async => pdfData,
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      context != null ? const PosSale().launch(context, isNewTask: true) : null;
    });
  }

  ///___________Quotation_PDF_Formats_______________________________________________________________________________________________________________________________________________________________
  FutureOr<Uint8List> generateQuotationDocument({required SaleTransactionModel transactions, required PersonalInformationModel personalInformation}) async {
    final pw.Document doc = pw.Document();

    double totalAmount({required SaleTransactionModel transactions}) {
      double amount = 0;

      for (var element in transactions.productList!) {
        amount = amount + double.parse(element.subTotal.toString()) * double.parse(element.quantity.toString());
      }

      return amount;
    }

    doc.addPage(
      pw.MultiPage(
        // pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: pw.EdgeInsets.zero,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20.0, right: 20, bottom: 20, top: 5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                ///________Company_Name_________________________________________________________
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10.0),
                  child: pw.Center(
                    child: pw.Text(
                      personalInformation.companyName,
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 22.0, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ),

                ///______Phone________________________________________________________________
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(1.0),
                  child: pw.Center(
                    child: pw.Text(
                      'Phone99: ${personalInformation.phoneNumber}',
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 14.0),
                    ),
                  ),
                ),

                ///______Address________________________________________________________________
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(1.0),
                  child: pw.Center(
                    child: pw.Text(
                      'Address99: ${personalInformation.countryName}',
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 14.0),
                    ),
                  ),
                ),

                ///______Shop_GST________________________________________________________________
                personalInformation.gst.trim().isNotEmpty
                    ? pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(1.0),
                        child: pw.Center(
                          child: pw.Text(
                            'Shop GST9: ${personalInformation.gst}',
                            style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 14.0),
                          ),
                        ),
                      )
                    : pw.Container(),

                ///________Bill/Invoice_________________________________________________________
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10.0),
                  child: pw.Center(
                      child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 0.5),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                          ),
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.only(top: 2.0, bottom: 2, left: 5, right: 5),
                            child: pw.Text(
                              'Bill/Invoice',
                              style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 16.0, fontWeight: pw.FontWeight.bold),
                            ),
                          ))),
                ),

                ///___________price_section_____________________________________________________
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  ///_________Left_Side__________________________________________________________
                  pw.Column(children: [
                    ///_____Name_______________________________________
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 60.0,
                        child: pw.Text(
                          'Customer',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 140.0,
                        child: pw.Text(
                          transactions.customerName,
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                    ]),

                    ///_____Phone_______________________________________
                    pw.SizedBox(height: 2),
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 60.0,
                        child: pw.Text(
                          'Phone',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 140.0,
                        child: pw.Text(
                          transactions.customerPhone,
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                    ]),

                    ///_____Address_______________________________________
                    pw.SizedBox(height: 2),
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 60.0,
                        child: pw.Text(
                          'Address',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 140.0,
                        child: pw.Text(
                          transactions.customerAddress,
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                    ]),

                    ///_____Party GST_______________________________________
                    pw.SizedBox(height: transactions.customerGst.trim().isNotEmpty ? 2 : 0),
                    transactions.customerGst.trim().isNotEmpty
                        ? pw.Row(children: [
                            pw.SizedBox(
                              width: 60.0,
                              child: pw.Text(
                                'Party GST',
                                style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                              ),
                            ),
                            pw.SizedBox(
                              width: 10.0,
                              child: pw.Text(
                                ':',
                                style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                              ),
                            ),
                            pw.SizedBox(
                              width: 140.0,
                              child: pw.Text(
                                transactions.customerGst,
                                style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                              ),
                            ),
                          ])
                        : pw.Container(),

                    ///_____Remarks_______________________________________
                    // pw.SizedBox(height: 2),
                    // pw.Row(children: [
                    //   pw.SizedBox(
                    //     width: 60.0,
                    //     child: pw.Text(
                    //       'Remarks',
                    //       style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                    //     ),
                    //   ),
                    //   pw.SizedBox(
                    //     width: 10.0,
                    //     child: pw.Text(
                    //       ':',
                    //       style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                    //     ),
                    //   ),
                    //   pw.SizedBox(
                    //     width: 140.0,
                    //     child: pw.Text(
                    //       '',
                    //       style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                    //     ),
                    //   ),
                    // ]),
                  ]),

                  ///_________Right_Side___________________________________________________________
                  pw.Column(children: [
                    ///______invoice_number_____________________________________________
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 50.0,
                        child: pw.Text(
                          'Invoice',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 125.0,
                        child: pw.Text(
                          '#${transactions.invoiceNumber}',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                    ]),
                    pw.SizedBox(height: 2),

                    ///_________Sells By________________________________________________
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 50.0,
                        child: pw.Text(
                          'Sells By',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 125.0,
                        child: pw.Text(
                          'Admin',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                    ]),
                    pw.SizedBox(height: 2),

                    ///______Date__________________________________________________________
                    pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.SizedBox(
                        width: 50.0,
                        child: pw.Text(
                          'Date',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.Container(
                        width: 125.0,
                        child: pw.Text(
                          '${DateFormat.yMd().format(DateTime.parse(transactions.purchaseDate))}, ${DateFormat.jm().format(DateTime.parse(transactions.purchaseDate))}',
                          // DateTimeFormat.format(DateTime.parse(transactions.purchaseDate), format: AmericanDateTimeFormats.),
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                    ]),
                    pw.SizedBox(height: 2),

                    ///______Status____________________________________________
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 50.0,
                        child: pw.Text(
                          'Status',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 125.0,
                        child: pw.Text(
                          transactions.isPaid! ? 'Paid' : 'Due',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ]),
                  ]),
                ]),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Column(children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(10.0),
              child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  child: pw.Column(children: [
                    pw.Container(
                      width: 120.0,
                      height: 1.0,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 4.0),
                    pw.Text(
                      'Signature of Customer',
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(
                            color: PdfColors.black,
                            fontSize: 11,
                          ),
                    )
                  ]),
                ),
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  child: pw.Column(children: [
                    pw.Container(
                      width: 120.0,
                      height: 1.0,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 4.0),
                    pw.Text(
                      'Authorized Signature',
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(
                            color: PdfColors.black,
                            fontSize: 11,
                          ),
                    )
                  ]),
                ),
              ]),
            ),
            pw.Text('Powered By $pdfFooter', style: const pw.TextStyle(fontSize: 10, color: PdfColors.black)),
            pw.SizedBox(height: 5),
          ]);
        },
        build: (pw.Context context) => <pw.Widget>[
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
            child: pw.Column(
              children: [
                ///___________Table__________________________________________________________
                pw.Table.fromTextArray(
                  context: context,
                  border: const pw.TableBorder(
                    left: pw.BorderSide(
                      color: PdfColors.grey600,
                    ),
                    right: pw.BorderSide(
                      color: PdfColors.grey600,
                    ),
                    bottom: pw.BorderSide(
                      color: PdfColors.grey600,
                    ),
                    top: pw.BorderSide(
                      color: PdfColors.grey600,
                    ),
                    verticalInside: pw.BorderSide(
                      color: PdfColors.grey600,
                    ),
                    horizontalInside: pw.BorderSide(
                      color: PdfColors.grey600,
                    ),
                  ),
                  // headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#D5D8DC')),
                  columnWidths: <int, pw.TableColumnWidth>{
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(6),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1.5),
                    4: const pw.FlexColumnWidth(1.7),
                    5: const pw.FlexColumnWidth(1.5),
                  },
                  headerStyle: pw.TextStyle(color: PdfColors.black, fontSize: 11, fontWeight: pw.FontWeight.bold),
                  rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
                  // oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  headerAlignments: <int, pw.Alignment>{
                    0: pw.Alignment.center,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.center,
                    3: pw.Alignment.center,
                    4: pw.Alignment.centerRight,
                    5: pw.Alignment.centerRight,
                  },
                  cellAlignments: <int, pw.Alignment>{
                    0: pw.Alignment.center,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.center,
                    3: pw.Alignment.center,
                    4: pw.Alignment.centerRight,
                    5: pw.Alignment.centerRight,
                  },
                  data: <List<String>>[
                    <String>['SL', 'Product Description', 'Warranty', 'Quantity', 'Unit Price', 'Price'],
                    for (int i = 0; i < transactions.productList!.length; i++)
                      <String>[
                        ('${i + 1}'),
                        (transactions.productList!.elementAt(i).productName.toString()),
                        (''),
                        (myFormat.format(double.tryParse(transactions.productList!.elementAt(i).quantity.toString()) ?? 0)),
                        (myFormat.format(double.tryParse(transactions.productList!.elementAt(i).subTotal.toString()) ?? 0)),
                        (myFormat.format(double.tryParse(
                                ((double.tryParse(transactions.productList!.elementAt(i).subTotal) ?? 0) * transactions.productList!.elementAt(i).quantity.toInt()).toString()) ??
                            0))
                      ],
                  ],
                ),
                // pw.SizedBox(width: 5),
                pw.Paragraph(text: ""),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text(
                        "Payment Method: Just Quotation",
                        style: const pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: 11,
                        ),
                      ),
                      pw.SizedBox(height: 10.0),
                      pw.Container(
                        width: 300,
                        child: pw.Text(
                          "In Word: ${amountToWords(transactions.totalAmount!.toInt())}",
                          maxLines: 3,
                          style: pw.TextStyle(color: PdfColors.black, fontSize: 11, fontWeight: pw.FontWeight.bold),
                        ),
                      )
                    ]),
                    pw.SizedBox(
                      width: 250.0,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Column(children: [
                            ///________Total_Amount_____________________________________
                            pw.Row(children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: pw.Text(
                                  'Total Amount',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                              pw.Container(
                                alignment: pw.Alignment.centerRight,
                                width: 150.0,
                                child: pw.Text(
                                  myFormat.format(double.tryParse(totalAmount(transactions: transactions).toString()) ?? 0),
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ]),
                            pw.SizedBox(height: 2),

                            ///________vat_______________________________________________
                            pw.ListView.builder(
                              itemCount: getAllTaxFromCartList(cart: transactions.productList ?? []).length,
                              itemBuilder: (context, index) {
                                return pw.Row(children: [
                                  pw.SizedBox(
                                    width: 100.0,
                                    child: pw.Text(
                                      getAllTaxFromCartList(cart: transactions.productList ?? [])[index].name,
                                      style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                            color: PdfColors.black,
                                            fontSize: 11,
                                          ),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.centerRight,
                                    width: 150.0,
                                    child: pw.Text(
                                      '${getAllTaxFromCartList(cart: transactions.productList ?? [])[index].taxRate}%',
                                      style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                            color: PdfColors.black,
                                            fontSize: 11,
                                          ),
                                    ),
                                  ),
                                ]);
                              },
                            ),
                            // pw.Row(children: [
                            //   pw.SizedBox(
                            //     width: 100.0,
                            //     child: pw.Text(
                            //       'Vat',
                            //       style: pw.Theme.of(context).defaultTextStyle.copyWith(
                            //             color: PdfColors.black,
                            //             fontSize: 11,
                            //           ),
                            //     ),
                            //   ),
                            //   pw.Container(
                            //     alignment: pw.Alignment.centerRight,
                            //     width: 150.0,
                            //     child: pw.Text(
                            //       myFormat.format(double.tryParse(transactions.vat.toString()) ?? 0),
                            //       style: pw.Theme.of(context).defaultTextStyle.copyWith(
                            //             color: PdfColors.black,
                            //             fontSize: 11,
                            //           ),
                            //     ),
                            //   ),
                            // ]),
                            pw.SizedBox(height: 2),

                            ///________Service/Shipping__________________________________
                            pw.Row(children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: pw.Text(
                                  "Service/Shipping",
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                              pw.Container(
                                alignment: pw.Alignment.centerRight,
                                width: 150.0,
                                child: pw.Text(
                                  myFormat.format(double.tryParse(transactions.serviceCharge.toString()) ?? 0),
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ]),
                            pw.SizedBox(height: 2),

                            ///_________divider__________________________________________
                            pw.Divider(thickness: .5, height: 0.5, color: PdfColors.black),
                            pw.SizedBox(height: 2),

                            ///________Sub Total Amount_______________________________________________
                            pw.Row(children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: pw.Text(
                                  'Sub-Total',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                              pw.Container(
                                alignment: pw.Alignment.centerRight,
                                width: 150.0,
                                child: pw.Text(
                                  myFormat.format(double.tryParse(
                                          (transactions.vat!.toDouble() + transactions.serviceCharge!.toDouble() + totalAmount(transactions: transactions)).toString()) ??
                                      0),
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ]),
                            pw.SizedBox(height: 2),

                            ///________Discount_______________________________________________
                            pw.Row(children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: pw.Text(
                                  'Discount',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                              pw.Container(
                                alignment: pw.Alignment.centerRight,
                                width: 150.0,
                                child: pw.Text(
                                  '- ${myFormat.format(double.tryParse(transactions.discountAmount.toString()) ?? 0)}',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ]),
                            pw.SizedBox(height: 2),

                            ///_________divider__________________________________________
                            pw.Divider(thickness: .5, height: 0.5, color: PdfColors.black),
                            pw.SizedBox(height: 2),

                            ///________payable_Amount_______________________________________________
                            pw.Row(children: [
                              pw.SizedBox(
                                width: 150.0,
                                child: pw.Text(
                                  'Net Payable Amount',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 11, fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                              pw.Container(
                                alignment: pw.Alignment.centerRight,
                                width: 100.0,
                                child: pw.Text(
                                  myFormat.format(double.tryParse(transactions.totalAmount.toString()) ?? 0),
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 11, fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                            ]),
                            pw.SizedBox(height: 2),

                            ///________Received_Amount_______________________________________________
                            pw.Row(children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: pw.Text(
                                  'Received Amount',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                              pw.Container(
                                alignment: pw.Alignment.centerRight,
                                width: 150.0,
                                child: pw.Text(
                                  myFormat.format(transactions.totalAmount! - transactions.dueAmount!),
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ]),
                            pw.SizedBox(height: 2),

                            ///_________divider__________________________________________
                            pw.Divider(thickness: .5, height: 0.5, color: PdfColors.black),
                            pw.SizedBox(height: 2),

                            ///________Received_Amount_______________________________________________
                            pw.Row(children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: pw.Text(
                                  'Due Amount',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                              // pw.SizedBox(
                              //   width: 10.0,
                              //   child: pw.Text(
                              //     ':',
                              //     style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                              //   ),
                              // ),
                              pw.Container(
                                alignment: pw.Alignment.centerRight,
                                width: 150.0,
                                child: pw.Text(
                                  myFormat.format(double.tryParse(transactions.dueAmount!.toString()) ?? 0),
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ]),
                            pw.SizedBox(height: 2),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Padding(padding: const pw.EdgeInsets.all(10)),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  ///___________Due_PDF_Formats_______________________________________________________________________________________________________________________________________________________________
  FutureOr<Uint8List> generateDueDocumentStyle2({required DueTransactionModel transactions, required PersonalInformationModel personalInformation}) async {
    final pw.Document doc = pw.Document();
    final netImage = await networkImage(
      'https://www.nfet.net/nfet.jpg',
    );
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: pw.EdgeInsets.zero,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20.0),
            child: pw.Column(
              children: [
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Container(
                    height: 50.0,
                    width: 50.0,
                    alignment: pw.Alignment.centerRight,
                    margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                    padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                    decoration: pw.BoxDecoration(image: pw.DecorationImage(image: netImage), shape: pw.BoxShape.circle),
                  ),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text(
                      personalInformation.companyName,
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 25.0, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Tel: ${personalInformation.phoneNumber!}',
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.red),
                    ),
                  ]),
                ]),
                pw.SizedBox(height: 30.0),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10.0, right: 10.0),
                    child: pw.Text(
                      'Payment Receipt',
                      style: pw.TextStyle(
                        color: PdfColors.purple300,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                ]),
                pw.SizedBox(height: 30.0),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text(
                      'Received From:',
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      transactions.customerName,
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Row(children: [
                      pw.Text(
                        'Contact No:',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                      pw.Text(
                        transactions.customerPhone,
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ]),
                  ]),
                  pw.Column(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                    pw.Row(children: [
                      pw.Text(
                        'Receipt No.:',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(
                              color: PdfColors.black,
                              fontWeight: pw.FontWeight.bold,
                            ),
                      ),
                      pw.Text(
                        '#${transactions.invoiceNumber}',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(
                              color: PdfColors.black,
                              fontWeight: pw.FontWeight.bold,
                            ),
                      ),
                    ]),
                    pw.Row(children: [
                      pw.Text(
                        'Date:',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                      pw.Text(
                        DateTimeFormat.format(
                          DateTime.parse(transactions.purchaseDate),
                        ).substring(0, 10),
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ]),
                  ]),
                ]),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Column(children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(10.0),
              child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  child: pw.Column(children: [
                    pw.Container(
                      width: 120.0,
                      height: 2.0,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 4.0),
                    pw.Text(
                      'Customer Signature',
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                    )
                  ]),
                ),
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  child: pw.Column(children: [
                    pw.Container(
                      width: 120.0,
                      height: 2.0,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 4.0),
                    pw.Text(
                      'Authorized Signature',
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                    )
                  ]),
                ),
              ]),
            ),
            pw.Container(
              width: double.infinity,
              color: PdfColors.black,
              padding: const pw.EdgeInsets.all(10.0),
              child: pw.Center(child: pw.Text('Powered By Pos Saas', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
            ),
          ]);
        },
        build: (pw.Context context) => <pw.Widget>[
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
            child: pw.Column(
              children: [
                pw.Paragraph(text: ""),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10.0),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(10.0),
                  ),
                  child: pw.Row(children: [
                    pw.Expanded(
                      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Text('Amount In Words',
                            style: pw.TextStyle(
                              color: PdfColors.black,
                              fontWeight: pw.FontWeight.bold,
                            )),
                        // pw.SizedBox(height: 10.0),
                        // pw.Container(
                        //   padding: const pw.EdgeInsets.all(4.0),
                        //   width: double.infinity,
                        //   color: PdfColors.grey50,
                        //   child: pw.Text(NumberToCharacterConverter('en').convertDouble(transactions.payDueAmount).toUpperCase(), style: const pw.TextStyle(color: PdfColors.black)),
                        // ),
                      ]),
                    ),
                    pw.SizedBox(width: 20.0),
                    pw.Expanded(
                        child: pw.Column(children: [
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                        pw.Text('Received', style: const pw.TextStyle(color: PdfColors.black)),
                        pw.Text(transactions.payDueAmount.toString(), style: const pw.TextStyle(color: PdfColors.black)),
                      ]),
                      pw.SizedBox(height: 4.0),
                      pw.Container(height: 3.0, width: double.infinity, color: PdfColors.grey50),
                    ])),
                  ]),
                ),
                pw.Padding(padding: const pw.EdgeInsets.all(10)),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  FutureOr<Uint8List> generateDueDocument({required DueTransactionModel transactions, required PersonalInformationModel personalInformation}) async {
    final pw.Document doc = pw.Document();
    final netImage = await networkImage(
      'https://www.nfet.net/nfet.jpg',
    );

    double totalAmount({required SaleTransactionModel transactions}) {
      double amount = 0;

      for (var element in transactions.productList!) {
        amount = amount + double.parse(element.subTotal.toString()) * double.parse(element.quantity.toString());
      }

      return amount;
    }

    doc.addPage(
      pw.MultiPage(
        // pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: pw.EdgeInsets.zero,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20.0, right: 20, bottom: 20, top: 5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                ///________Company_Name_________________________________________________________
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10.0),
                  child: pw.Center(
                    child: pw.Text(
                      personalInformation.companyName,
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 22.0, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ),

                ///______Phone________________________________________________________________
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(1.0),
                  child: pw.Center(
                    child: pw.Text(
                      'Phone: ${personalInformation.phoneNumber}',
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 14.0),
                    ),
                  ),
                ),

                ///______Address________________________________________________________________
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(1.0),
                  child: pw.Center(
                    child: pw.Text(
                      'Address: ${personalInformation.countryName}',
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 14.0),
                    ),
                  ),
                ),

                ///______Shop_GST________________________________________________________________
                personalInformation.gst.trim().isNotEmpty
                    ? pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(1.0),
                        child: pw.Center(
                          child: pw.Text(
                            'Shop GST: ${personalInformation.gst}',
                            style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 14.0),
                          ),
                        ),
                      )
                    : pw.Container(),

                ///________Bill/Invoice_________________________________________________________
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10.0),
                  child: pw.Center(
                      child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 0.5),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                          ),
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.only(top: 2.0, bottom: 2, left: 5, right: 5),
                            child: pw.Text(
                              'Bill/Invoice',
                              style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 16.0, fontWeight: pw.FontWeight.bold),
                            ),
                          ))),
                ),

                ///___________price_section_____________________________________________________
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  ///_________Left_Side__________________________________________________________
                  pw.Column(children: [
                    ///_____Name_______________________________________
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 60.0,
                        child: pw.Text(
                          'Customer',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 140.0,
                        child: pw.Text(
                          transactions.customerName,
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                    ]),

                    ///_____Phone_______________________________________
                    pw.SizedBox(height: 2),
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 60.0,
                        child: pw.Text(
                          'Phone',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 140.0,
                        child: pw.Text(
                          transactions.customerPhone,
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                    ]),

                    ///_____Address_______________________________________
                    pw.SizedBox(height: 2),
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 60.0,
                        child: pw.Text(
                          'Address',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 140.0,
                        child: pw.Text(
                          transactions.customerAddress,
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                    ]),

                    ///_____Party GST_______________________________________
                    pw.SizedBox(height: transactions.customerGst.trim().isNotEmpty ? 2 : 0),
                    transactions.customerGst.trim().isNotEmpty
                        ? pw.Row(children: [
                            pw.SizedBox(
                              width: 60.0,
                              child: pw.Text(
                                'Party GST',
                                style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                              ),
                            ),
                            pw.SizedBox(
                              width: 10.0,
                              child: pw.Text(
                                ':',
                                style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                              ),
                            ),
                            pw.SizedBox(
                              width: 140.0,
                              child: pw.Text(
                                transactions.customerGst,
                                style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                              ),
                            ),
                          ])
                        : pw.Container(),

                    ///_____Remarks_______________________________________
                    // pw.SizedBox(height: 2),
                    // pw.Row(children: [
                    //   pw.SizedBox(
                    //     width: 60.0,
                    //     child: pw.Text(
                    //       'Remarks',
                    //       style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                    //     ),
                    //   ),
                    //   pw.SizedBox(
                    //     width: 10.0,
                    //     child: pw.Text(
                    //       ':',
                    //       style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                    //     ),
                    //   ),
                    //   pw.SizedBox(
                    //     width: 140.0,
                    //     child: pw.Text(
                    //       '',
                    //       style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                    //     ),
                    //   ),
                    // ]),
                  ]),

                  ///_________Right_Side___________________________________________________________
                  pw.Column(children: [
                    ///______invoice_number_____________________________________________
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 50.0,
                        child: pw.Text(
                          'Invoice',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 125.0,
                        child: pw.Text(
                          '#${transactions.invoiceNumber}',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                    ]),
                    pw.SizedBox(height: 2),

                    ///_________Sells By________________________________________________
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 50.0,
                        child: pw.Text(
                          'Sells By',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 125.0,
                        child: pw.Text(
                          'Admin',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                    ]),
                    pw.SizedBox(height: 2),

                    ///______Date__________________________________________________________
                    pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.SizedBox(
                        width: 50.0,
                        child: pw.Text(
                          'Date',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.Container(
                        width: 125.0,
                        child: pw.Text(
                          '${DateFormat.yMd().format(DateTime.parse(transactions.purchaseDate))}, ${DateFormat.jm().format(DateTime.parse(transactions.purchaseDate))}',
                          // DateTimeFormat.format(DateTime.parse(transactions.purchaseDate), format: AmericanDateTimeFormats.),
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                    ]),
                    pw.SizedBox(height: 2),

                    ///______Status____________________________________________
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 50.0,
                        child: pw.Text(
                          'Status',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 125.0,
                        child: pw.Text(
                          transactions.isPaid! ? 'Paid' : 'Due',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ]),
                  ]),
                ]),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Column(children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(10.0),
              child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  child: pw.Column(children: [
                    pw.Container(
                      width: 120.0,
                      height: 1.0,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 4.0),
                    pw.Text(
                      'Signature of Customer',
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(
                            color: PdfColors.black,
                            fontSize: 11,
                          ),
                    )
                  ]),
                ),
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  child: pw.Column(children: [
                    pw.Container(
                      width: 120.0,
                      height: 1.0,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 4.0),
                    pw.Text(
                      'Authorized Signature',
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(
                            color: PdfColors.black,
                            fontSize: 11,
                          ),
                    )
                  ]),
                ),
              ]),
            ),
            pw.SizedBox(height: 5),
            pw.Text('Powered By $pdfFooter', style: const pw.TextStyle(fontSize: 10, color: PdfColors.black)),
          ]);
        },
        build: (pw.Context context) => <pw.Widget>[
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
            child: pw.Column(
              children: [
                ///___________Table__________________________________________________________
                pw.Table.fromTextArray(
                  context: context,
                  border: const pw.TableBorder(
                    left: pw.BorderSide(
                      color: PdfColors.grey600,
                    ),
                    right: pw.BorderSide(
                      color: PdfColors.grey600,
                    ),
                    bottom: pw.BorderSide(
                      color: PdfColors.grey600,
                    ),
                    top: pw.BorderSide(
                      color: PdfColors.grey600,
                    ),
                    verticalInside: pw.BorderSide(
                      color: PdfColors.grey600,
                    ),
                    horizontalInside: pw.BorderSide(
                      color: PdfColors.grey600,
                    ),
                  ),
                  // headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#D5D8DC')),
                  columnWidths: <int, pw.TableColumnWidth>{
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(6),
                    2: const pw.FlexColumnWidth(2),
                  },
                  headerStyle: pw.TextStyle(color: PdfColors.black, fontSize: 11, fontWeight: pw.FontWeight.bold),
                  rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
                  // oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  headerAlignments: <int, pw.Alignment>{
                    0: pw.Alignment.center,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.center,
                  },
                  cellAlignments: <int, pw.Alignment>{
                    0: pw.Alignment.center,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.center,
                  },
                  data: <List<String>>[
                    <String>['SL', 'Due Description', 'due Amount'],
                    <String>[('${1}'), ('Previous Due'), (transactions.totalDue.toString())],
                  ],
                ),
                // pw.SizedBox(width: 5),
                pw.Paragraph(text: ""),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text(
                        "Payment Method: ${transactions.paymentType}",
                        style: const pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: 11,
                        ),
                      ),
                      pw.SizedBox(height: 10.0),
                      pw.Container(
                        width: 300,
                        child: pw.Text(
                          "In Word: ${amountToWords(transactions.payDueAmount!.toInt())}",
                          maxLines: 3,
                          style: pw.TextStyle(color: PdfColors.black, fontSize: 11, fontWeight: pw.FontWeight.bold),
                        ),
                      )
                    ]),
                    pw.SizedBox(
                      width: 250.0,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Column(children: [
                            ///________Total_Amount_____________________________________
                            pw.Row(children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: pw.Text(
                                  'Total Due Amount',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                              pw.Container(
                                alignment: pw.Alignment.centerRight,
                                width: 150.0,
                                child: pw.Text(
                                  transactions.totalDue.toString(),
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ]),
                            pw.SizedBox(height: 2),

                            ///________vat_______________________________________________
                            pw.Row(children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: pw.Text(
                                  'Vat',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                              pw.Container(
                                alignment: pw.Alignment.centerRight,
                                width: 150.0,
                                child: pw.Text(
                                  '0',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ]),
                            pw.SizedBox(height: 2),

                            ///________Service/Shipping__________________________________
                            pw.Row(children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: pw.Text(
                                  "Service/Shipping",
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                              pw.Container(
                                alignment: pw.Alignment.centerRight,
                                width: 150.0,
                                child: pw.Text(
                                  '0',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ]),
                            pw.SizedBox(height: 2),

                            ///_________divider__________________________________________
                            pw.Divider(thickness: .5, height: 0.5, color: PdfColors.black),
                            pw.SizedBox(height: 2),

                            ///________Sub Total Amount_______________________________________________
                            pw.Row(children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: pw.Text(
                                  'Sub-Total',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                              pw.Container(
                                alignment: pw.Alignment.centerRight,
                                width: 150.0,
                                child: pw.Text(
                                  transactions.totalDue.toString(),
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ]),
                            pw.SizedBox(height: 2),

                            ///________Discount_______________________________________________
                            pw.Row(children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: pw.Text(
                                  'Discount',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                              pw.Container(
                                alignment: pw.Alignment.centerRight,
                                width: 150.0,
                                child: pw.Text(
                                  '- 0',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ]),
                            pw.SizedBox(height: 2),

                            ///_________divider__________________________________________
                            pw.Divider(thickness: .5, height: 0.5, color: PdfColors.black),
                            pw.SizedBox(height: 2),

                            ///________payable_Amount_______________________________________________
                            pw.Row(children: [
                              pw.SizedBox(
                                width: 150.0,
                                child: pw.Text(
                                  'Net Payable Amount',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 11, fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                              pw.Container(
                                alignment: pw.Alignment.centerRight,
                                width: 100.0,
                                child: pw.Text(
                                  transactions.totalDue.toString(),
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 11, fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                            ]),
                            pw.SizedBox(height: 2),

                            ///________Received_Amount_______________________________________________
                            pw.Row(children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: pw.Text(
                                  'Received Amount',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                              pw.Container(
                                alignment: pw.Alignment.centerRight,
                                width: 150.0,
                                child: pw.Text(
                                  "${transactions.payDueAmount}",
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ]),
                            pw.SizedBox(height: 2),

                            ///_________divider__________________________________________
                            pw.Divider(thickness: .5, height: 0.5, color: PdfColors.black),
                            pw.SizedBox(height: 2),

                            ///________Received_Amount_______________________________________________
                            pw.Row(children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: pw.Text(
                                  'Due Amount',
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                              // pw.SizedBox(
                              //   width: 10.0,
                              //   child: pw.Text(
                              //     ':',
                              //     style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                              //   ),
                              // ),
                              pw.Container(
                                alignment: pw.Alignment.centerRight,
                                width: 150.0,
                                child: pw.Text(
                                  transactions.dueAmountAfterPay!.toString(),
                                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                                        color: PdfColors.black,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ]),
                            pw.SizedBox(height: 2),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Padding(padding: const pw.EdgeInsets.all(10)),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  Future<void> printSaleLedger(
      {required PersonalInformationModel personalInformationModel,
      required List<SaleTransactionModel> saleTransactionModel,
      required CustomerModel customer,
      BuildContext? context}) async {
    await Printing.layoutPdf(
      dynamicLayout: true,
      onLayout: (PdfPageFormat format) async => await generateLedgerDocument(
        personalInformationModel: personalInformationModel,
        saleTransactionModel: saleTransactionModel,
        customer: customer,
      ),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      context != null ? const LedgerScreen().launch(context, isNewTask: true) : null;
    });
  }

  Future<void> printPurchaseLedger(
      {required PersonalInformationModel personalInformationModel,
      required List<PurchaseTransactionModel> purchaseTransactionModel,
      required CustomerModel customer,
      BuildContext? context}) async {
    await Printing.layoutPdf(
      dynamicLayout: true,
      onLayout: (PdfPageFormat format) async => await generatePurchaseLedgerDocument(
        personalInformationModel: personalInformationModel,
        purchaseTransactionModel: purchaseTransactionModel,
        customer: customer,
      ),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      context != null ? const LedgerScreen().launch(context, isNewTask: true) : null;
    });
  }
}

FutureOr<Uint8List> generateLedgerDocument(
    {required PersonalInformationModel personalInformationModel,
    required List<SaleTransactionModel> saleTransactionModel,
    required CustomerModel customer,
    BuildContext? context}) async {
  final pw.Document doc = pw.Document();

  double total = 0;
  double receivedAmount = 0;
  double dueAmount = 0;
  for (var element in saleTransactionModel) {
    total = total + double.parse(element.totalAmount.toString());
    dueAmount = dueAmount + double.parse(element.dueAmount.toString());
    receivedAmount = receivedAmount + (double.tryParse((element.totalAmount! - element.dueAmount!.toDouble()).toString()) ?? 0);
  }

  doc.addPage(
    pw.MultiPage(
      // pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
      margin: pw.EdgeInsets.zero,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      header: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 20.0, right: 20, bottom: 20, top: 5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              ///________Company_Name_________________________________________________________
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10.0),
                child: pw.Center(
                  child: pw.Text(
                    personalInformationModel.companyName,
                    style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 22.0, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ),

              ///________Bill/Invoice_________________________________________________________
              pw.Center(
                  child: pw.Text(
                'Party Ledger',
                style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 16.0, fontWeight: pw.FontWeight.bold),
              )),

              ///___________price_section_____________________________________________________
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                ///_________Left_Side__________________________________________________________
                pw.Column(children: [
                  ///_____Name_______________________________________
                  pw.Row(children: [
                    pw.SizedBox(
                      width: 60.0,
                      child: pw.Text(
                        'Party Name',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                    pw.SizedBox(
                      width: 10.0,
                      child: pw.Text(
                        ':',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                    pw.SizedBox(
                      width: 140.0,
                      child: pw.Text(
                        saleTransactionModel.first.customerName,
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                  ]),

                  ///_____Phone_______________________________________
                  pw.SizedBox(height: 2),
                  pw.Row(children: [
                    pw.SizedBox(
                      width: 60.0,
                      child: pw.Text(
                        'Phone',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                    pw.SizedBox(
                      width: 10.0,
                      child: pw.Text(
                        ':',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                    pw.SizedBox(
                      width: 140.0,
                      child: pw.Text(
                        saleTransactionModel.first.customerPhone,
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                  ]),

                  ///_____Address_______________________________________
                  pw.SizedBox(height: 2),
                  pw.Row(children: [
                    pw.SizedBox(
                      width: 60.0,
                      child: pw.Text(
                        'Address',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                    pw.SizedBox(
                      width: 10.0,
                      child: pw.Text(
                        ':',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                    pw.SizedBox(
                      width: 140.0,
                      child: pw.Text(
                        saleTransactionModel.first.customerAddress,
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                  ]),
                ]),
              ]),
            ],
          ),
        );
      },
      footer: (pw.Context context) {
        return pw.Column(children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(10.0),
            child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Container(
                alignment: pw.Alignment.centerRight,
                margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                child: pw.Column(children: [
                  pw.Container(
                    width: 120.0,
                    height: 1.0,
                    color: PdfColors.black,
                  ),
                  pw.SizedBox(height: 4.0),
                  pw.Text(
                    'Account Manager',
                    style: pw.Theme.of(context).defaultTextStyle.copyWith(
                          color: PdfColors.black,
                          fontSize: 11,
                        ),
                  )
                ]),
              ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                child: pw.Column(children: [
                  pw.Container(
                    width: 120.0,
                    height: 1.0,
                    color: PdfColors.black,
                  ),
                  pw.SizedBox(height: 4.0),
                  pw.Text(
                    'Prepared by',
                    style: pw.Theme.of(context).defaultTextStyle.copyWith(
                          color: PdfColors.black,
                          fontSize: 11,
                        ),
                  )
                ]),
              ),
            ]),
          ),
          pw.Text('Powered By $pdfFooter', style: const pw.TextStyle(fontSize: 10, color: PdfColors.black)),
          pw.SizedBox(height: 5),
        ]);
      },
      build: (pw.Context context) => <pw.Widget>[
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
          child: pw.Column(
            children: [
              ///___________Table__________________________________________________________
              pw.TableHelper.fromTextArray(
                context: context,
                border: const pw.TableBorder(
                  left: pw.BorderSide(
                    color: PdfColors.grey600,
                  ),
                  right: pw.BorderSide(
                    color: PdfColors.grey600,
                  ),
                  bottom: pw.BorderSide(
                    color: PdfColors.grey600,
                  ),
                  top: pw.BorderSide(
                    color: PdfColors.grey600,
                  ),
                  verticalInside: pw.BorderSide(
                    color: PdfColors.grey600,
                  ),
                  horizontalInside: pw.BorderSide(
                    color: PdfColors.grey600,
                  ),
                ),
                // headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#D5D8DC')),
                columnWidths: <int, pw.TableColumnWidth>{
                  0: const pw.FlexColumnWidth(1.5),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(1.5),
                  5: const pw.FlexColumnWidth(1.5),
                  6: const pw.FlexColumnWidth(2),
                  7: const pw.FlexColumnWidth(2),
                },
                headerStyle: pw.TextStyle(color: PdfColors.black, fontSize: 11, fontWeight: pw.FontWeight.bold),
                rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
                // oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                headerAlignments: <int, pw.Alignment>{
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                  5: pw.Alignment.center,
                  6: pw.Alignment.center,
                  7: pw.Alignment.center,
                },
                cellAlignments: <int, pw.Alignment>{
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                  5: pw.Alignment.centerRight,
                  6: pw.Alignment.centerRight,
                  7: pw.Alignment.centerRight,
                },
                data: <List<String>>[
                  <String>[
                    'Date',
                    'Type',
                    'Payment Type',
                    'Received by',
                    'Invoice',
                    'Sale Amount',
                    'Received',
                    'Due',
                  ],
                  for (int i = 0; i < saleTransactionModel.length; i++)
                    <String>[
                      (DateFormat.yMd().format(DateTime.parse(saleTransactionModel.elementAt(i).purchaseDate.toString()))),
                      ('Sale'),
                      (saleTransactionModel.elementAt(i).paymentType.toString()),
                      ('Admin'),
                      (saleTransactionModel.elementAt(i).invoiceNumber.toString()),
                      ('$currency${myFormat.format(double.tryParse(saleTransactionModel.elementAt(i).totalAmount.toString()) ?? 0)}'),
                      ('$currency${myFormat.format(double.tryParse((saleTransactionModel.elementAt(i).totalAmount!.toDouble() - saleTransactionModel.elementAt(i).dueAmount!.toDouble()).toString()) ?? 0)}'),
                      ('$currency${myFormat.format(double.tryParse(saleTransactionModel.elementAt(i).dueAmount.toString()) ?? 0)}'),
                    ],
                  <String>['', '', '', '', 'Grand Total', '$currency$total', '$currency$receivedAmount', '$currency$dueAmount'],
                ],
              ),
              // pw.SizedBox(width: 5),
              pw.Paragraph(text: ""),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                pw.Text(
                  'Closing balance: $currency$total',
                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                        color: PdfColors.black,
                        fontSize: 11,
                      ),
                ),
              ])
            ],
          ),
        ),
      ],
    ),
  );

  return doc.save();
}

FutureOr<Uint8List> generatePurchaseLedgerDocument(
    {required PersonalInformationModel personalInformationModel,
    required List<PurchaseTransactionModel> purchaseTransactionModel,
    required CustomerModel customer,
    BuildContext? context}) async {
  final pw.Document doc = pw.Document();

  double total = 0;
  double receivedAmount = 0;
  double dueAmount = 0;
  for (var element in purchaseTransactionModel) {
    total = total + double.parse(element.totalAmount.toString());
    dueAmount = dueAmount + double.parse(element.dueAmount.toString());
    receivedAmount = receivedAmount + (double.tryParse((element.totalAmount! - element.dueAmount!.toDouble()).toString()) ?? 0);
  }

  doc.addPage(
    pw.MultiPage(
      // pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
      margin: pw.EdgeInsets.zero,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      header: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 20.0, right: 20, bottom: 20, top: 5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              ///________Company_Name_________________________________________________________
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10.0),
                child: pw.Center(
                  child: pw.Text(
                    personalInformationModel.companyName,
                    style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 22.0, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ),

              ///________Bill/Invoice_________________________________________________________
              pw.Center(
                  child: pw.Text(
                'Party Ledger',
                style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 16.0, fontWeight: pw.FontWeight.bold),
              )),

              ///___________price_section_____________________________________________________
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                ///_________Left_Side__________________________________________________________
                pw.Column(children: [
                  ///_____Name_______________________________________
                  pw.Row(children: [
                    pw.SizedBox(
                      width: 60.0,
                      child: pw.Text(
                        'Supplier',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                    pw.SizedBox(
                      width: 10.0,
                      child: pw.Text(
                        ':',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                    pw.SizedBox(
                      width: 140.0,
                      child: pw.Text(
                        purchaseTransactionModel.first.customerName,
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                  ]),

                  ///_____Phone_______________________________________
                  pw.SizedBox(height: 2),
                  pw.Row(children: [
                    pw.SizedBox(
                      width: 60.0,
                      child: pw.Text(
                        'Phone',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                    pw.SizedBox(
                      width: 10.0,
                      child: pw.Text(
                        ':',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                    pw.SizedBox(
                      width: 140.0,
                      child: pw.Text(
                        purchaseTransactionModel.first.customerPhone,
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                  ]),

                  ///_____Address_______________________________________
                  pw.SizedBox(height: 2),
                  pw.Row(children: [
                    pw.SizedBox(
                      width: 60.0,
                      child: pw.Text(
                        'Address',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                    pw.SizedBox(
                      width: 10.0,
                      child: pw.Text(
                        ':',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                    pw.SizedBox(
                      width: 140.0,
                      child: pw.Text(
                        purchaseTransactionModel.first.customerAddress,
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                      ),
                    ),
                  ]),
                ]),
              ]),
            ],
          ),
        );
      },
      footer: (pw.Context context) {
        return pw.Column(children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(10.0),
            child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Container(
                alignment: pw.Alignment.centerRight,
                margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                child: pw.Column(children: [
                  pw.Container(
                    width: 120.0,
                    height: 1.0,
                    color: PdfColors.black,
                  ),
                  pw.SizedBox(height: 4.0),
                  pw.Text(
                    'Account Manager',
                    style: pw.Theme.of(context).defaultTextStyle.copyWith(
                          color: PdfColors.black,
                          fontSize: 11,
                        ),
                  )
                ]),
              ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                child: pw.Column(children: [
                  pw.Container(
                    width: 120.0,
                    height: 1.0,
                    color: PdfColors.black,
                  ),
                  pw.SizedBox(height: 4.0),
                  pw.Text(
                    'Prepared by',
                    style: pw.Theme.of(context).defaultTextStyle.copyWith(
                          color: PdfColors.black,
                          fontSize: 11,
                        ),
                  )
                ]),
              ),
            ]),
          ),
          pw.Text('Powered By $pdfFooter', style: const pw.TextStyle(fontSize: 10, color: PdfColors.black)),
          pw.SizedBox(height: 5),
        ]);
      },
      build: (pw.Context context) => <pw.Widget>[
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
          child: pw.Column(
            children: [
              ///___________Table__________________________________________________________
              pw.TableHelper.fromTextArray(
                context: context,
                border: const pw.TableBorder(
                  left: pw.BorderSide(
                    color: PdfColors.grey600,
                  ),
                  right: pw.BorderSide(
                    color: PdfColors.grey600,
                  ),
                  bottom: pw.BorderSide(
                    color: PdfColors.grey600,
                  ),
                  top: pw.BorderSide(
                    color: PdfColors.grey600,
                  ),
                  verticalInside: pw.BorderSide(
                    color: PdfColors.grey600,
                  ),
                  horizontalInside: pw.BorderSide(
                    color: PdfColors.grey600,
                  ),
                ),
                // headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#D5D8DC')),
                columnWidths: <int, pw.TableColumnWidth>{
                  0: const pw.FlexColumnWidth(1.5),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(1.5),
                  5: const pw.FlexColumnWidth(1.5),
                  6: const pw.FlexColumnWidth(2),
                  7: const pw.FlexColumnWidth(2),
                },
                headerStyle: pw.TextStyle(color: PdfColors.black, fontSize: 11, fontWeight: pw.FontWeight.bold),
                rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
                // oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                headerAlignments: <int, pw.Alignment>{
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                  5: pw.Alignment.center,
                  6: pw.Alignment.center,
                  7: pw.Alignment.center,
                },
                cellAlignments: <int, pw.Alignment>{
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                  5: pw.Alignment.centerRight,
                  6: pw.Alignment.centerRight,
                  7: pw.Alignment.centerRight,
                },
                data: <List<String>>[
                  <String>[
                    'Date',
                    'Type',
                    'Payment Type',
                    'Received by',
                    'Invoice',
                    'Sale Amount',
                    'Received',
                    'Due',
                  ],
                  for (int i = 0; i < purchaseTransactionModel.length; i++)
                    <String>[
                      (DateFormat.yMd().format(DateTime.parse(purchaseTransactionModel.elementAt(i).purchaseDate.toString()))),
                      ('Purchase'),
                      (purchaseTransactionModel.elementAt(i).paymentType.toString()),
                      ('Admin'),
                      (purchaseTransactionModel.elementAt(i).invoiceNumber.toString()),
                      ('$currency${myFormat.format(double.tryParse(purchaseTransactionModel.elementAt(i).totalAmount.toString()) ?? 0)}'),
                      ('$currency${myFormat.format(double.tryParse((purchaseTransactionModel.elementAt(i).totalAmount!.toDouble() - purchaseTransactionModel.elementAt(i).dueAmount!.toDouble()).toString()) ?? 0)}'),
                      ('$currency${myFormat.format(double.tryParse(purchaseTransactionModel.elementAt(i).dueAmount.toString()) ?? 0)}'),
                    ],
                  <String>['', '', '', '', 'Grand Total', '$currency$total', '$currency$receivedAmount', '$currency$dueAmount'],
                ],
              ),
              // pw.SizedBox(width: 5),
              pw.Paragraph(text: ""),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                pw.Text(
                  'Closing balance: $currency$total',
                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                        color: PdfColors.black,
                        fontSize: 11,
                      ),
                ),
              ])
            ],
          ),
        ),
      ],
    ),
  );

  return doc.save();
}

String amountToWords(int amount) {
  final List<String> units = ['', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'];
  final List<String> tens = ['', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'];
  final List<String> teens = ['ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'];

  if (amount == 0) {
    return 'zero';
  }

  String words = '';
  if ((amount ~/ 1000) > 0) {
    words += '${amountToWords(amount ~/ 1000)} thousand ';
    amount %= 1000;
  }
  if ((amount ~/ 100) > 0) {
    words += '${units[amount ~/ 100]} hundred ';
    amount %= 100;
  }
  if (amount > 0) {
    if (words.isNotEmpty) {
      words += 'and ';
    }
    if (amount < 10) {
      words += units[amount];
    } else if (amount < 20) {
      words += teens[amount - 10];
    } else {
      words += '${tens[amount ~/ 10]} ${units[amount % 10]}';
    }
  }

  return words.trim();
}
