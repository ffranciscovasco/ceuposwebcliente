import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/Authentication/log_in.dart';
import 'package:salespro_admin/Screen/Authentication/tablet_signup.dart';
import 'package:salespro_admin/Screen/Widgets/Constant%20Data/button_global.dart';
import 'package:salespro_admin/responsive.dart' as res;
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../../Repository/signup_repo.dart';
import '../../const.dart';
import '../Widgets/Constant Data/constant.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);
  static const String route = '/signup';

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  bool passwordShow = false;
  String? givenPassword;
  String? givenPassword2;

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate() && givenPassword == givenPassword2) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkWhite,
      body: res.Responsive(
        mobile: Container(),
        tablet: const TabletSignUp(),
        desktop: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final auth = ref.watch(signUpProvider);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * .50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Column(
                            children: [
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
                                '$appsName Painel de inscrição',
                                style: kTextStyle.copyWith(color: kGreyTextColor, fontWeight: FontWeight.bold, fontSize: 21.0),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10.0),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Form(
                                  key: globalKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AppTextField(
                                              showCursor: true,
                                              cursorColor: kTitleColor,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'O e-mail não pode estar vazio';
                                                } else if (!value.contains('@')) {
                                                  return 'Por favor insira um e-mail válido';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) {
                                                auth.email = value;
                                              },
                                              textFieldType: TextFieldType.EMAIL,
                                              decoration: kInputDecoration.copyWith(
                                                labelText: lang.S.of(context).email,
                                                labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                                hintText: lang.S.of(context).enterYourEmailAddress,
                                                hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20.0),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AppTextField(
                                              showCursor: true,
                                              cursorColor: kTitleColor,
                                              textFieldType: TextFieldType.PASSWORD,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'A senha não pode ficar vazia';
                                                } else if (value.length < 4) {
                                                  return 'Por favor insira uma senha maior';
                                                } else if (value.length < 4) {
                                                  return 'Por favor insira uma senha maior';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) {
                                                auth.password = value;
                                                givenPassword = value;
                                              },
                                              decoration: kInputDecoration.copyWith(
                                                labelText: lang.S.of(context).password,
                                                labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                                hintText: lang.S.of(context).enterYourPassword,
                                                hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20.0),
                                          Expanded(
                                            child: AppTextField(
                                              showCursor: true,
                                              cursorColor: kTitleColor,
                                              textFieldType: TextFieldType.PASSWORD,
                                              onChanged: (value) {
                                                givenPassword2 = value;
                                              },
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'A senha não pode ficar vazia';
                                                } else if (value.length < 4) {
                                                  return 'Por favor insira uma senha maior';
                                                } else if (givenPassword != givenPassword2) {
                                                  return 'Senha não corresponde';
                                                }
                                                return null;
                                              },
                                              decoration: kInputDecoration.copyWith(
                                                labelText: lang.S.of(context).confirmPassword,
                                                labelStyle: kTextStyle.copyWith(color: kTitleColor),
                                                hintText: lang.S.of(context).enterYourPasswordAgain,
                                                hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20.0),
                                      ButtonGlobal(
                                          buttontext: lang.S.of(context).registration,
                                          buttonDecoration: kButtonDecoration.copyWith(color: kGreenTextColor, borderRadius: BorderRadius.circular(8.0)),
                                          onPressed: (() {
                                            if (validateAndSave()) {
                                              auth.signUp(context);
                                            }
                                          })),
                                      const SizedBox(height: 20.0),
                                      RichText(
                                        text: TextSpan(
                                          text: lang.S.of(context).alreadyHaveAnAccounts,
                                          style: kTextStyle.copyWith(color: kTitleColor),
                                          children: [
                                            TextSpan(
                                              text: lang.S.of(context).login,
                                              style: kTextStyle.copyWith(color: kGreenTextColor),
                                            )
                                          ],
                                        ),
                                      ).onTap(
                                        () => Navigator.of(context).pushNamed(EmailLogIn.route),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
