import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Repository/login_repo.dart';
import 'package:salespro_admin/Screen/Authentication/sign_up.dart';
import 'package:salespro_admin/Screen/Widgets/Constant%20Data/button_global.dart';
import 'package:salespro_admin/const.dart';
import '../../Repository/signup_repo.dart';
import '../Widgets/Constant Data/constant.dart';
import 'forgot_password.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;

class EmailLogIn extends StatefulWidget {
  const EmailLogIn({super.key});

  static const String route = '/login/email';

  @override
  State<EmailLogIn> createState() => _EmailLogInState();
}

class _EmailLogInState extends State<EmailLogIn> {
  late String email, password;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  String? user;

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<bool> checkUser({required BuildContext context}) async {
    final isActive = await PurchaseModel().isActiveBuyer();
    if (isActive) {
      validateAndSave();
      return true;
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Not Active User"),
          content: const Text("Please use the valid purchase code to use the app."),
          actions: [
            TextButton(
              onPressed: () {
                // Exit app
                if (Platform.isAndroid) {
                  SystemNavigator.pop();
                } else {
                  exit(0);
                }
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return false;
    }
  }

  void showPopUP() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SizedBox(
            height: 400,
            width: 600,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        FeatherIcons.x,
                        color: kTitleColor,
                      ).onTap(() {
                        finish(context);
                      }),
                    ],
                  ),
                  const SizedBox(height: 100.0),
                  Text(
                    lang.S.of(context).pleaseDownloadOurMobileApp,
                    textAlign: TextAlign.center,
                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 21.0),
                  ),
                  const SizedBox(height: 50.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 60,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          image: const DecorationImage(image: AssetImage('images/playstore.png'), fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Container(
                        height: 60,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          image: const DecorationImage(image: AssetImage('images/appstore.png'), fit: BoxFit.cover),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  var currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kDarkWhite,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: context.width() < 750 ? 750 : MediaQuery.of(context).size.width,
              height: context.height() < 500 ? 500 : MediaQuery.of(context).size.height,
              child: Consumer(builder: (context, ref, watch) {
                final loginProvider = ref.watch(logInProvider);
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Container(
                      width: context.width() < 940 ? 477 : MediaQuery.of(context).size.width * .50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10.0),
                          Container(
                            height: 100,
                            width: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(appLogo),
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 1.0,
                            color: kGreyTextColor.withOpacity(0.1),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            '$appsName Painel de login',
                            style: kTextStyle.copyWith(color: kGreyTextColor, fontWeight: FontWeight.bold, fontSize: 21.0),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10.0),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: globalKey,
                              child: Column(
                                children: [
                                  AppTextField(
                                    showCursor: true,
                                    cursorColor: kTitleColor,
                                    textFieldType: TextFieldType.EMAIL,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'O e-mail não pode estar vazio';
                                      } else if (!value.contains('@')) {
                                        return 'Por favor insira um e-mail válido';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      loginProvider.email = value;
                                    },
                                    decoration: kInputDecoration.copyWith(
                                      labelText: lang.S.of(context).email,
                                      labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                      hintText: lang.S.of(context).enterYourEmailAddress,
                                      hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                      prefixIcon: const Icon(FeatherIcons.mail, color: kTitleColor),
                                    ),
                                  ),
                                  const SizedBox(height: 20.0),
                                  AppTextField(
                                    showCursor: true,
                                    cursorColor: kTitleColor,
                                    textFieldType: TextFieldType.PASSWORD,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'A senha não pode ficar vazia';
                                      } else if (value.length < 4) {
                                        return 'Por favor insira uma senha maior';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      loginProvider.password = value;
                                    },
                                    decoration: kInputDecoration.copyWith(
                                      labelText: lang.S.of(context).password,
                                      labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                      hintText: lang.S.of(context).enterYourPassword,
                                      hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                      prefixIcon: const Icon(FeatherIcons.lock, color: kTitleColor),
                                    ),
                                  ),
                                  const SizedBox(height: 20.0),
                                  ButtonGlobal(
                                    buttontext: lang.S.of(context).login,
                                    buttonDecoration: kButtonDecoration.copyWith(color: kGreenTextColor, borderRadius: BorderRadius.circular(8.0)),
                                    onPressed: () async {
                                        if (validateAndSave()) {
                                          loginProvider.signIn(context);
                                        }
                                    },
                                  ),
                                  const SizedBox(height: 20.0),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            Navigator.pushNamed(context, ForgotPassword.route);
                                          },
                                          icon: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                MdiIcons.lockAlertOutline,
                                                color: kTitleColor,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 5.0),
                                              Text(
                                                lang.S.of(context).forgotPassword,
                                                textAlign: TextAlign.center,
                                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                              )
                                            ],
                                          )),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, SignUp.route);
                                        },
                                        child: Text(
                                          lang.S.of(context).registration,
                                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.end,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ));
  }
}
