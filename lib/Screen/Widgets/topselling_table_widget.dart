import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/commas.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../currency.dart';
import '../../model/home_report_model.dart';
import 'Constant Data/constant.dart';

class MtTopStock extends StatelessWidget {
  const MtTopStock({
    Key? key,
    required this.report,
  }) : super(key: key);

  final List<TopPurchaseReport> report;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: kWhite),
      child: Column(
        children: [
          Container(
            height: 57,
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 15.0, 15.0),
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(color: kBorderColorTextField, width: 2.0),
            )),
            child: Row(
              children: [
                const Icon(FontAwesomeIcons.boxOpen, size: 18.0, color: kGreyTextColor),
                const SizedBox(width: 10.0),
                Flexible(
                  child: Text(
                    lang.S.of(context).fivePurchase,
                    style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor, fontSize: 16.0, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
          report.isNotEmpty
              ? ListView.builder(
                  itemCount: report.length < 5 ? report.length : 5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, i) {
                    report.sort((a, b) => b.stock!.compareTo(a.stock.toString()));
                    return (ListTile(
                      leading: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(report[i].image ?? ''),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(color: kBorderColorTextField),
                            shape: BoxShape.circle),
                      ),
                      title: Text(
                        report[i].name ?? '',
                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        report[i].category ?? '',
                        style: kTextStyle.copyWith(color: kGreyTextColor),
                      ),
                      trailing: Text(
                        myFormat.format(double.tryParse(report[i].stock ?? '') ?? 0),
                        style: kTextStyle.copyWith(color: kTitleColor, fontSize: 16.0),
                      ),
                      contentPadding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      horizontalTitleGap: 10,
                    ));
                  })
              : const Center(
                  child: Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text('List is empty'),
                )),
        ],
      ),
    );
  }
}

class TopSellingProduct extends StatelessWidget {
  const TopSellingProduct({
    super.key,
    required this.report,
  });

  final List<TopSellReport> report;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: kWhite),
      child: Column(
        children: [
          Container(
            height: 57,
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 15.0, 15.0),
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(color: kBorderColorTextField, width: 2.0),
            )),
            child: Row(
              children: [
                const Icon(FontAwesomeIcons.boxOpen, size: 18.0, color: kGreyTextColor),
                const SizedBox(width: 10.0),
                Text(
                  lang.S.of(context).topSellingProduct,
                  style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor, fontSize: 16.0),
                ),
              ],
            ),
          ),
          ListView.builder(
              itemCount: report.length < 5 ? report.length : 5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, i) {
                return (ListTile(
                  leading: Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      image: DecorationImage(image: NetworkImage(report[i].productImage ?? ''), fit: BoxFit.cover),
                      border: Border.all(color: kBorderColorTextField),
                    ),
                  ),
                  // leading: Container(
                  //   height: 50.0,
                  //   width: 50.0,
                  //   decoration: const BoxDecoration(
                  //       color: Color(0xFF8424FF),
                  //       // border: Border.all(color: kBorderColorTextField),
                  //       shape: BoxShape.circle),
                  //   child: Center(
                  //     child: Text(
                  //       report[i].name?.substring(0, 2) ?? '',
                  //       style: kTextStyle.copyWith(color: kWhiteTextColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                  //     ),
                  //   ),
                  // ),
                  title: Text(
                    report[i].name ?? '',
                    style: kTextStyle.copyWith(color: kTitleColor, fontSize: 18.0),
                  ),
                  subtitle: Text(
                    '${lang.S.of(context).totalSale}: ${report[i].stock ?? ''}',
                    style: kTextStyle.copyWith(color: kGreyTextColor),
                  ),
                  trailing: Text(
                    "$currency ${myFormat.format(double.tryParse(report[i].amount ?? '') ?? 0)}",
                    style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 16.0),
                  ),
                  contentPadding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  horizontalTitleGap: 10,
                ));
              })
        ],
      ),
    );
  }
}

class TopCustomerTable extends StatelessWidget {
  const TopCustomerTable({
    super.key,
    required this.report,
  });

  final List<TopCustomer> report;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: kWhite),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 57,
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 15.0, 15.0),
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(color: kBorderColorTextField, width: 2.0),
            )),
            child: Row(
              children: [
                const Icon(FontAwesomeIcons.users, size: 18.0, color: kGreyTextColor),
                const SizedBox(width: 10.0),
                Text(
                  lang.S.of(context).customerOfTheMonth,
                  style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor, fontSize: 16.0),
                ),
              ],
            ),
          ),
          report.isNotEmpty
              ? ListView.builder(
                  itemCount: report.length < 5 ? report.length : 5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, i) {
                    return (ListTile(
                      leading: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          image: DecorationImage(image: NetworkImage(report[i].image ?? ''), fit: BoxFit.cover),
                          border: Border.all(color: kBorderColorTextField),
                        ),
                      ),
                      title: Text(
                        report[i].name ?? '',
                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                      ),
                      subtitle: Text(
                        report[i].phone ?? '',
                        style: kTextStyle.copyWith(color: kGreyTextColor, overflow: TextOverflow.ellipsis),
                      ),
                      trailing: Text(
                        "$currency ${myFormat.format(double.tryParse(report[i].amount ?? '') ?? 0)}",
                        style: kTextStyle.copyWith(color: kTitleColor, fontSize: 16, overflow: TextOverflow.ellipsis),
                      ),
                      contentPadding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      horizontalTitleGap: 16,
                    ));
                  },
                )
              : const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: Text('List is empty')),
                )
        ],
      ),
    );
  }
}
