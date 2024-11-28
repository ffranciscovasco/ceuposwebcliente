import 'package:flutter/material.dart';
import 'package:salespro_admin/Screen/tax%20rates/tax_rates_widget.dart';
import '../Reports/current_stock_widget.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import '../Widgets/TopBar/top_bar_widget.dart';

class TaxRates extends StatefulWidget {
  const TaxRates({super.key});
  static const String route = '/taxRates';

  @override
  State<TaxRates> createState() => _TaxRatesState();
}

class _TaxRatesState extends State<TaxRates> {
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
                  index: 17,
                  isTab: false,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width < 1275 ? 1275 - 240 : MediaQuery.of(context).size.width - 240,
                // width: context.width() < 1080 ? 1080 - 240 : MediaQuery.of(context).size.width - 240,
                decoration: const BoxDecoration(color: kDarkWhite),
                child: const SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //_______________________________top_bar____________________________
                      TopBar(),

                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TaxRatesWidget(),
                          ],
                        ),
                      ),
                      // Visibility(visible: MediaQuery.of(context).size.height != 0, child: const Footer()),
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
