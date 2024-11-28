import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/Subscription/payment.dart';
import 'package:salespro_admin/Screen/Subscription/subscript.dart';
import '../../Provider/subacription_plan_provider.dart';
import '../../Repository/subscriptionPlanRepo.dart';
import '../../const.dart';
import '../../currency.dart';
import '../../model/subscription_model.dart';
import '../../model/subscription_plan_model.dart';
import '../Widgets/Constant Data/constant.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../Widgets/Footer/footer.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';

import '../Widgets/TopBar/top_bar_widget.dart';

class PurchasePlan extends StatefulWidget {
  const PurchasePlan({
    Key? key,
    required this.initialSelectedPackage,
    required this.initPackageValue,
  }) : super(key: key);
  final String initialSelectedPackage;
  final int initPackageValue;
  static const String route = '/purchase_plan';

  @override
  // ignore: library_private_types_in_public_api
  _PurchasePlanState createState() => _PurchasePlanState();
}

class _PurchasePlanState extends State<PurchasePlan> {
  ScrollController mainScroll = ScrollController();

  String selectedPayButton = 'Paypal';
  int selectedPackageValue = 0;

  CurrentSubscriptionPlanRepo currentSubscriptionPlanRepo = CurrentSubscriptionPlanRepo();

  SubscriptionModel currentSubscriptionPlan = SubscriptionModel(
    subscriptionName: 'Free',
    subscriptionDate: DateTime.now().toString(),
    saleNumber: 0,
    purchaseNumber: 0,
    partiesNumber: 0,
    dueNumber: 0,
    duration: 0,
    products: 0,
  );

  void getCurrentSubscriptionPlan() async {
    currentSubscriptionPlan = await currentSubscriptionPlanRepo.getCurrentSubscriptionPlans();
    setState(() {
      currentSubscriptionPlan;
    });
  }

  @override
  initState() {
    super.initState();
    checkCurrentUserAndRestartApp();
    getCurrentSubscriptionPlan();
    widget.initPackageValue == 0 ? selectedPackageValue = 2 : 0;
  }

  List<Color> colors = [
    const Color(0xFF06DE90),
    const Color(0xFFF5B400),
    const Color(0xFFFF7468),
  ];
  SubscriptionPlanModel selectedPlan =
      SubscriptionPlanModel(subscriptionName: '', saleNumber: 0, purchaseNumber: 0, partiesNumber: 0, dueNumber: 0, duration: 0, products: 0, subscriptionPrice: 0, offerPrice: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkWhite,
      body: Consumer(builder: (context, ref, __) {
        final subscriptionData = ref.watch(subscriptionPlanProvider);
        return Scrollbar(
          controller: mainScroll,
          child: SingleChildScrollView(
            controller: mainScroll,
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 240,
                  child: SideBarWidget(
                    index: 15,
                    isTab: false,
                  ),
                ),
                subscriptionData.when(data: (data) {
                  return Container(
                    width: MediaQuery.of(context).size.width < 1275 ? 1275 - 240 : MediaQuery.of(context).size.width - 240,
                    // width: context.width() < 1080 ? 1080 - 240 : MediaQuery.of(context).size.width - 240,
                    decoration: const BoxDecoration(color: kDarkWhite),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          //_______________________________top_bar____________________________
                          const TopBar(),

                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: kWhite),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.S.of(context).purchasePremiumPlan,
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                  ),
                                  Divider(
                                    thickness: 1.0,
                                    color: kGreyTextColor.withOpacity(0.1),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        insetPadding: const EdgeInsets.symmetric(horizontal: 200),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            const SizedBox(height: 20),
                                                            Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                GestureDetector(
                                                                  child: const Icon(Icons.cancel),
                                                                  onTap: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                ),
                                                                const SizedBox(width: 20),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 20),
                                                            Container(
                                                              height: 200,
                                                              width: 200,
                                                              decoration:
                                                                  const BoxDecoration(image: DecorationImage(image: AssetImage('images/plan_details_1.png'), fit: BoxFit.cover)),
                                                            ),
                                                            const SizedBox(height: 20),
                                                            Text(
                                                              lang.S.of(context).freeLifeTimeUpdate,
                                                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                            ),
                                                            const SizedBox(height: 15),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 20.0, right: 20),
                                                              child: Text(lang.S.of(context).stayAtTheForeFrontOfTechnological,
                                                                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                                                            ),
                                                            const SizedBox(height: 20),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Card(
                                                  elevation: 1.0,
                                                  shadowColor: Colors.grey.shade700,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(2.0),
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(2.0),
                                                      color: Colors.white,
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color: kDarkWhite,
                                                          spreadRadius: 1.0,
                                                          blurRadius: 7,
                                                          offset: Offset(0, 2),
                                                        )
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          height: 40,
                                                          width: 40,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(2.0),
                                                            image: const DecorationImage(
                                                              image: AssetImage('images/sp1.png'),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          lang.S.of(context).freeLifeTimeUpdate,
                                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                        ),
                                                        const Spacer(),
                                                        const Icon(FeatherIcons.alertCircle),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20.0),
                                            Expanded(
                                              flex: 1,
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        insetPadding: const EdgeInsets.symmetric(horizontal: 200),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            const SizedBox(height: 20),
                                                            Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                GestureDetector(
                                                                  child: const Icon(Icons.cancel),
                                                                  onTap: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                ),
                                                                const SizedBox(width: 20),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 20),
                                                            Container(
                                                              height: 200,
                                                              width: 200,
                                                              decoration:
                                                                  const BoxDecoration(image: DecorationImage(image: AssetImage('images/plan_details_2.png'), fit: BoxFit.cover)),
                                                            ),
                                                            const SizedBox(height: 20),
                                                            Text(
                                                              lang.S.of(context).androidIOSAppSupport,
                                                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                            ),
                                                            const SizedBox(height: 15),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 20.0, right: 20),
                                                              child: Text(lang.S.of(context).weUnderStand, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                                                            ),
                                                            const SizedBox(height: 20),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Card(
                                                  elevation: 1.0,
                                                  shadowColor: Colors.grey.shade700,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(2.0),
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(2.0),
                                                      color: Colors.white,
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color: kDarkWhite,
                                                          spreadRadius: 1.0,
                                                          blurRadius: 7,
                                                          offset: Offset(0, 2),
                                                        )
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          height: 40,
                                                          width: 40,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(2.0),
                                                            image: const DecorationImage(
                                                              image: AssetImage('images/sp2.png'),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          lang.S.of(context).androidIOSAppSupport,
                                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                        ),
                                                        const Spacer(),
                                                        const Icon(FeatherIcons.alertCircle),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20.0),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        insetPadding: const EdgeInsets.symmetric(horizontal: 200),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            const SizedBox(height: 20),
                                                            Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                GestureDetector(
                                                                  child: const Icon(Icons.cancel),
                                                                  onTap: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                ),
                                                                const SizedBox(width: 20),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 20),
                                                            Container(
                                                              height: 200,
                                                              width: 200,
                                                              decoration:
                                                                  const BoxDecoration(image: DecorationImage(image: AssetImage('images/plan_details_3.png'), fit: BoxFit.cover)),
                                                            ),
                                                            const SizedBox(height: 20),
                                                            Text(
                                                              lang.S.of(context).premiumCustomerSupport,
                                                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                            ),
                                                            const SizedBox(height: 15),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 20.0, right: 20),
                                                              child: Text(lang.S.of(context).unlockTheFull, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                                                            ),
                                                            const SizedBox(height: 20),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Card(
                                                  elevation: 1.0,
                                                  shadowColor: Colors.grey.shade700,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(2.0),
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(2.0),
                                                      color: Colors.white,
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color: kDarkWhite,
                                                          spreadRadius: 1.0,
                                                          blurRadius: 7,
                                                          offset: Offset(0, 2),
                                                        )
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          height: 40,
                                                          width: 40,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(2.0),
                                                            image: const DecorationImage(
                                                              image: AssetImage('images/sp3.png'),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          lang.S.of(context).premiumCustomerSupport,
                                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                        ),
                                                        const Spacer(),
                                                        const Icon(FeatherIcons.alertCircle),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20.0),
                                            Expanded(
                                              flex: 1,
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        insetPadding: const EdgeInsets.symmetric(horizontal: 200),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            const SizedBox(height: 20),
                                                            Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                GestureDetector(
                                                                  child: const Icon(Icons.cancel),
                                                                  onTap: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                ),
                                                                const SizedBox(width: 20),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 20),
                                                            Container(
                                                              height: 200,
                                                              width: 200,
                                                              decoration:
                                                                  const BoxDecoration(image: DecorationImage(image: AssetImage('images/plan_details_4.png'), fit: BoxFit.cover)),
                                                            ),
                                                            const SizedBox(height: 20),
                                                            Text(
                                                              lang.S.of(context).customInvoiceBranding,
                                                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                            ),
                                                            const SizedBox(height: 15),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 20.0, right: 20),
                                                              child: Text(lang.S.of(context).makeALastingImpression,
                                                                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                                                            ),
                                                            const SizedBox(height: 20),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Card(
                                                  elevation: 1.0,
                                                  shadowColor: Colors.grey.shade700,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(2.0),
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(2.0),
                                                      color: Colors.white,
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color: kDarkWhite,
                                                          spreadRadius: 1.0,
                                                          blurRadius: 7,
                                                          offset: Offset(0, 2),
                                                        )
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          height: 40,
                                                          width: 40,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(2.0),
                                                            image: const DecorationImage(
                                                              image: AssetImage('images/sp4.png'),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          lang.S.of(context).customInvoiceBranding,
                                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                        ),
                                                        const Spacer(),
                                                        const Icon(FeatherIcons.alertCircle),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20.0),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        insetPadding: const EdgeInsets.symmetric(horizontal: 200),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            const SizedBox(height: 20),
                                                            Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                GestureDetector(
                                                                  child: const Icon(Icons.cancel),
                                                                  onTap: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                ),
                                                                const SizedBox(width: 20),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 20),
                                                            Container(
                                                              height: 200,
                                                              width: 200,
                                                              decoration:
                                                                  const BoxDecoration(image: DecorationImage(image: AssetImage('images/plan_details_5.png'), fit: BoxFit.cover)),
                                                            ),
                                                            const SizedBox(height: 20),
                                                            Text(
                                                              lang.S.of(context).unlimitedUsage,
                                                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                            ),
                                                            const SizedBox(height: 15),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 20.0, right: 20),
                                                              child: Text(lang.S.of(context).theNameSysIt, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                                                            ),
                                                            const SizedBox(height: 20),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Card(
                                                  elevation: 1.0,
                                                  shadowColor: Colors.grey.shade700,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(2.0),
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(2.0),
                                                      color: Colors.white,
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color: kDarkWhite,
                                                          spreadRadius: 1.0,
                                                          blurRadius: 7,
                                                          offset: Offset(0, 2),
                                                        )
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          height: 40,
                                                          width: 40,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(2.0),
                                                            image: const DecorationImage(
                                                              image: AssetImage('images/sp5.png'),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          lang.S.of(context).unlimitedUsage,
                                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                        ),
                                                        const Spacer(),
                                                        const Icon(FeatherIcons.alertCircle),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20.0),
                                            Expanded(
                                              flex: 1,
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        insetPadding: const EdgeInsets.symmetric(horizontal: 200),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            const SizedBox(height: 20),
                                                            Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                GestureDetector(
                                                                  child: const Icon(Icons.cancel),
                                                                  onTap: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                ),
                                                                const SizedBox(width: 20),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 20),
                                                            Container(
                                                              height: 200,
                                                              width: 200,
                                                              decoration:
                                                                  const BoxDecoration(image: DecorationImage(image: AssetImage('images/plan_details_6.png'), fit: BoxFit.cover)),
                                                            ),
                                                            const SizedBox(height: 20),
                                                            Text(
                                                              lang.S.of(context).freeDataBackup,
                                                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                            ),
                                                            const SizedBox(height: 15),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 20.0, right: 20),
                                                              child: Text(lang.S.of(context).safegurardYourBusinessDate,
                                                                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                                                            ),
                                                            const SizedBox(height: 20),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Card(
                                                  elevation: 1.0,
                                                  shadowColor: Colors.grey.shade700,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(2.0),
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(2.0),
                                                      color: Colors.white,
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color: kDarkWhite,
                                                          spreadRadius: 1.0,
                                                          blurRadius: 7,
                                                          offset: Offset(0, 2),
                                                        )
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          height: 40,
                                                          width: 40,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(2.0),
                                                            image: const DecorationImage(
                                                              image: AssetImage('images/sp6.png'),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          lang.S.of(context).freeDataBackup,
                                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                        ),
                                                        const Spacer(),
                                                        const Icon(FeatherIcons.alertCircle),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      lang.S.of(context).buyPremiumPlan,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 225,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.only(left: 20.0),
                                      physics: const ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: data.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedPlan = data[index];
                                            });
                                          },
                                          child: data[index].offerPrice >= 1
                                              ? Padding(
                                                  padding: const EdgeInsets.only(right: 10),
                                                  child: SizedBox(
                                                    height: (context.width() / 2.5) + 18,
                                                    child: Stack(
                                                      alignment: Alignment.bottomCenter,
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color:
                                                                data[index].subscriptionName == selectedPlan.subscriptionName ? kPremiumPlanColor2.withOpacity(0.1) : Colors.white,
                                                            borderRadius: const BorderRadius.all(
                                                              Radius.circular(10),
                                                            ),
                                                            border: Border.all(
                                                              width: 1,
                                                              color: data[index].subscriptionName == selectedPlan.subscriptionName ? kPremiumPlanColor2 : kPremiumPlanColor,
                                                            ),
                                                          ),
                                                          padding: const EdgeInsets.all(10.0),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              const SizedBox(height: 15),
                                                              Text(
                                                                lang.S.of(context).mobilePlusDesktop,
                                                                textAlign: TextAlign.center,
                                                                style: const TextStyle(
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 15),
                                                              Text(
                                                                data[index].subscriptionName,
                                                                style: const TextStyle(fontSize: 16),
                                                              ),
                                                              const SizedBox(height: 5),
                                                              Text(
                                                                '${data[index].offerPrice} $currency',
                                                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPremiumPlanColor2),
                                                              ),
                                                              Text(
                                                                '${data[index].subscriptionPrice} $currency',
                                                                style: const TextStyle(decoration: TextDecoration.lineThrough, fontSize: 14, color: Colors.grey),
                                                              ),
                                                              const SizedBox(height: 5),
                                                              Text(
                                                                'Duração ${data[index].duration} Dia(s)',
                                                                style: const TextStyle(color: kGreyTextColor),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: 0,
                                                          left: 0,
                                                          child: Container(
                                                            height: 25,
                                                            width: 70,
                                                            decoration: const BoxDecoration(
                                                              color: kPremiumPlanColor2,
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(10),
                                                                bottomRight: Radius.circular(10),
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                '${(100 - ((data[index].offerPrice * 100) / data[index].subscriptionPrice)).toInt().toString()}%',
                                                                style: const TextStyle(color: Colors.white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Padding(
                                                  padding: const EdgeInsets.only(bottom: 20, right: 10),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10.0),
                                                    decoration: BoxDecoration(
                                                      color: data[index].subscriptionName == selectedPlan.subscriptionName ? kPremiumPlanColor2.withOpacity(0.1) : Colors.white,
                                                      borderRadius: const BorderRadius.all(
                                                        Radius.circular(10),
                                                      ),
                                                      border: Border.all(
                                                          width: 1, color: data[index].subscriptionName == selectedPlan.subscriptionName ? kPremiumPlanColor2 : kPremiumPlanColor),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          lang.S.of(context).mobilePlusDesktop,
                                                          textAlign: TextAlign.center,
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 15),
                                                        Text(
                                                          data[index].subscriptionName,
                                                          style: const TextStyle(fontSize: 16),
                                                        ),
                                                        const SizedBox(height: 5),
                                                        Text(
                                                          '${data[index].subscriptionPrice.toString()} $currency',
                                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPremiumPlanColor),
                                                        ),
                                                        const SizedBox(height: 5),
                                                        Text(
                                                          'Duração ${data[index].duration} Dia(s)',
                                                          style: const TextStyle(color: kGreyTextColor),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Center(
                                    child: SizedBox(
                                      height: 40.0,
                                      width: MediaQuery.of(context).size.width < 1080 ? 1080 * .30 : MediaQuery.of(context).size.width * .30,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                          backgroundColor: kMainColor,
                                          textStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (selectedPlan.subscriptionName == '') {
                                            EasyLoading.showError('Por favor selecione um Plano');
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PaymentScreen(
                                                  subscriptionPlanModel: selectedPlan,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          'Renovar/Mudar Plano',
                                          style: kTextStyle.copyWith(color: kWhite, fontSize: 18.0),
                                        ),
                                      ),
                                    ),
                                  ).visible(Subscript.customersActivePlan.subscriptionName != selectedPlan.subscriptionName),
                                  const SizedBox(height: 15),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          const Footer(),
                        ],
                      ),
                    ),
                  );
                }, error: (Object error, StackTrace? stackTrace) {
                  return Text(error.toString());
                }, loading: () {
                  return const Center(child: CircularProgressIndicator());
                }),
              ],
            ),
          ),
        );
      }),
    );
  }
}
