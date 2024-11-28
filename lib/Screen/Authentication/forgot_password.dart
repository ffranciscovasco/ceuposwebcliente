import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Screen/Authentication/log_in.dart';
import 'package:salespro_admin/const.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import '../Widgets/Constant Data/button_global.dart';
import '../Widgets/Constant Data/constant.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);
  static const String route = '/resetPassword';
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late String email;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkWhite,
      body: Column(
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
                          lang.S.of(context).resetYourPassword,
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
                                    email = value;
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
                                ButtonGlobal(
                                    buttontext: lang.S.of(context).resetYourPassword,
                                    buttonDecoration: kButtonDecoration.copyWith(color: kGreenTextColor, borderRadius: BorderRadius.circular(8.0)),
                                    onPressed: (() async {
                                      if (validateAndSave()) {
                                        try {
                                          EasyLoading.show(status: "Enviando e-mail de redefinição..");
                                          // await FirebaseAuth.instance.sendPasswordResetEmail(
                                          //   email: email,
                                          // );
                                          await FirebaseAuth.instance.sendPasswordResetEmail(
                                            email: email,
                                          );
                                          EasyLoading.showSuccess('Enviado com sucesso, verifique sua caixa de entrada');
                                          if (!mounted) return;
                                          Navigator.pushNamed(context, EmailLogIn.route);
                                        } on FirebaseAuthException catch (e) {
                                          if (e.code == 'user-not-found') {
                                            EasyLoading.showError('Nenhum usuário encontrado para esse e-mail.');
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Nenhum usuário encontrado para esse e-maill.'),
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                          } else if (e.code == 'wrong-password') {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Senha errada fornecida para esse usuário.'),
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          EasyLoading.showError(e.toString());
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                              duration: const Duration(seconds: 3),
                                            ),
                                          );
                                        }
                                      }
                                    })),
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
      ),
    );
  }
}
