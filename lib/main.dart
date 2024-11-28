import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salespro_admin/Language/language_provider.dart';
import 'package:salespro_admin/Screen/Authentication/log_in.dart';
import 'package:salespro_admin/Screen/Inventory%20Sales/inventory_sales.dart';
import 'package:salespro_admin/Screen/Subscription/payment.dart';
import 'package:salespro_admin/Screen/Subscription/purchase_plan.dart';
import 'package:salespro_admin/Screen/Subscription/subscription_plan_page.dart';
import 'package:salespro_admin/Screen/Authentication/sign_up.dart';
import 'package:salespro_admin/Screen/Authentication/tablet_log_in.dart';
import 'package:salespro_admin/Screen/Customer%20List/customer_list.dart';
import 'package:salespro_admin/Screen/Due%20List/due_list_screen.dart';
import 'package:salespro_admin/Screen/Expenses/expenses_list.dart';
import 'package:salespro_admin/Screen/Expenses/new_expense.dart';
import 'package:salespro_admin/Screen/Home/home_screen.dart';
import 'package:salespro_admin/Screen/Income/income_list.dart';
import 'package:salespro_admin/Screen/Ledger%20Screen/ledger_screen.dart';
import 'package:salespro_admin/Screen/LossProfit/lossProfit_screen.dart';
import 'package:salespro_admin/Screen/POS%20Sale/pos_sale.dart';
import 'package:salespro_admin/Screen/Payment%20Handler/payment_cancel.dart';
import 'package:salespro_admin/Screen/Payment%20Handler/payment_success.dart';
import 'package:salespro_admin/Screen/Purchase/purchase.dart';
import 'package:salespro_admin/Screen/Reports/report_screen.dart';
import 'package:salespro_admin/Screen/Sales%20Return/sales_returns_list.dart';
import 'package:salespro_admin/Screen/Supplier%20List/supplier_list.dart';
import 'package:salespro_admin/Screen/Widgets/invoice_url_redirection.dart';
import 'package:salespro_admin/Screen/daily_tanasaction.dart';
import 'package:salespro_admin/const.dart';
import 'package:url_strategy/url_strategy.dart';
import 'Screen/Authentication/forgot_password.dart';
import 'Screen/Authentication/tablet_signup.dart';
import 'Screen/HRM/Designation/designation_list.dart';
import 'Screen/HRM/employees/employee_list.dart';
import 'Screen/HRM/salaries list/salaries_list_screen.dart';
import 'Screen/Income/new_income.dart';
import 'Screen/Product/product barcode/barcode_generate.dart';
import 'Screen/Product/product.dart';
import 'Screen/Purchase List/purchase_list.dart';
import 'Screen/Purchase Return/purchase_returns_list.dart';
import 'Screen/Quotation List/quotation_list.dart';
import 'Screen/Sale List/sale_list.dart';
import 'Screen/Settings/settings_screen.dart';
import 'Screen/Stock List/stock_list_screen.dart';
import 'Screen/User Role System/user_role_screen.dart';
import 'Screen/WareHouse/ware_house_list.dart';
import 'Screen/Warranty/warranty_screen.dart';
import 'Screen/Whatsapp Marketing/whatsapp_marketing_screen.dart';
import 'Screen/Widgets/Constant Data/constant.dart';
import 'Screen/tax rates/tax_rate_screen.dart';
import 'firebase_options.dart';
import 'model/paypal_info_model.dart';
import 'dart:html' as html;
import 'generated/l10n.dart';
import 'package:provider/provider.dart' as pro;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  html.window.onBeforeUnload.listen((event) async {});
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getPaypalInfo();
    // Subscription.getUserLimitsData(context: context,wannaShowMsg: true);
    return pro.ChangeNotifierProvider<LanguageChangeProvider>(
        create: (context) => LanguageChangeProvider(),
        child: Builder(
            builder: (context) => MaterialApp(
                  locale: pro.Provider.of<LanguageChangeProvider>(context, listen: true).currentLocale,
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: S.delegate.supportedLocales,
                  builder: EasyLoading.init(),
                  debugShowCheckedModeBanner: false,
                  title: appsTitle,
                  theme: ThemeData(fontFamily: 'Display'),
                  onGenerateRoute: generateRoute,
                  initialRoute: '/',
                  routes: {
                    '/': (context) => const EmailLogIn(),
                    // '/': (context) => const MtHomeScreen(),
                    EmailLogIn.route: (context) => const EmailLogIn(),
                    MtHomeScreen.route: (context) => const MtHomeScreen(),
                    PosSale.route: (context) => const PosSale(),
                    Purchase.route: (context) => const Purchase(),
                    Product.route: (context) => const Product(),
                    InventorySales.route: (context) => const InventorySales(),
                    SupplierList.route: (context) => const SupplierList(),
                    CustomerList.route: (context) => const CustomerList(),
                    ExpensesList.route: (context) => const ExpensesList(),
                    IncomeList.route: (context) => const IncomeList(),
                    NewExpense.route: (context) => const NewExpense(),
                    NewIncome.route: (context) => const NewIncome(),
                    SaleReports.route: (context) => const SaleReports(),
                    QuotationList.route: (context) => const QuotationList(),
                    SettingsScreen.route: (context) => const SettingsScreen(),
                    WhatsappMarketingScreen.route: (context) => const WhatsappMarketingScreen(),
                    // NidVerification.route: (context) => const NidVerification(),
                    WarrantyScreen.route: (context) => const WarrantyScreen(),
                    // PricingPage.route: (context) =>  PricingPage(),
                    PaymentSuccess.route: (context) => const PaymentSuccess(),
                    PaymentCancel.route: (context) => const PaymentCancel(),
                    SaleList.route: (context) => const SaleList(),
                    SalesReturn.route: (context) => const SalesReturn(),
                    PurchaseReturn.route: (context) => const PurchaseReturn(),
                    PurchaseList.route: (context) => const PurchaseList(),
                    // LogIn.route: (context) => const LogIn(),
                    ForgotPassword.route: (context) => const ForgotPassword(),
                    SignUp.route: (context) => const SignUp(),
                    TabletLogIn.route: (context) => const TabletLogIn(),
                    TabletSignUp.route: (context) => const TabletSignUp(),
                    UserRoleScreen.route: (context) => const UserRoleScreen(),
                    DailyTransactionScreen.route: (context) => const DailyTransactionScreen(),

                    LedgerScreen.route: (context) => const LedgerScreen(),
                    LossProfitScreen.route: (context) => const LossProfitScreen(),
                    DueList.route: (context) => const DueList(),
                    SubscriptionPage.route: (context) => const SubscriptionPage(),
                    StockListScreen.route: (context) => const StockListScreen(),
                    BarcodeGenerate.route: (context) => const BarcodeGenerate(),
                    WareHouseList.route: (context) => const WareHouseList(),
                    PaymentScreen.route: (context) => const PaymentScreen(
                          subscriptionPlanModel: null,
                        ),
                    PurchasePlan.route: (context) => const PurchasePlan(initialSelectedPackage: 'Yearly', initPackageValue: 0),

                    // TabletSaleReport.route: (context) => const TabletSaleReport(),
                    TaxRates.route: (context) => const TaxRates(),
                    DesignationListScreen.route: (context) => const DesignationListScreen(),
                    EmployeeListScreen.route: (context) => const EmployeeListScreen(),
                    SalariesListScreen.route: (context) => const SalariesListScreen(),
                  },
                )));
  }

  Future<void> getPaypalInfo() async {
    DatabaseReference paypalRef = FirebaseDatabase.instance.ref('Admin Panel/Paypal Info');
    final paypalData = await paypalRef.get();
    PaypalInfoModel paypalInfoModel = PaypalInfoModel.fromJson(jsonDecode(jsonEncode(paypalData.value)));

    paypalClientId = paypalInfoModel.paypalClientId;
    paypalClientSecret = paypalInfoModel.paypalClientSecret;
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    var uri = Uri.parse(settings.name!);
    print(uri.path);
    if(uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'invoices'){
      return MaterialPageRoute(builder: (_) => const InvoiceRedirectPage());
    }
    switch (uri.path) {
      case 'success/':
        return MaterialPageRoute(builder: (_) => const PaymentSuccess());
      default:
        return MaterialPageRoute(builder: (_) => const SignUp());
    }
  }
}
