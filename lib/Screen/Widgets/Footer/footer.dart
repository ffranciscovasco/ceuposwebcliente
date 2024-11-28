import 'package:flutter/cupertino.dart';
import 'package:salespro_admin/Screen/Widgets/Constant%20Data/constant.dart';

import '../../../const.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
      ),
      child: Row(
        children: [
          Text(
            'COPYRIGHT © 2024 $appsName, Todos os direitos reservados',
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              text: 'Feito Por',
              children: [
                TextSpan(
                  text: ' $madeBy',
                  style: kTextStyle.copyWith(color: kMainColor),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
