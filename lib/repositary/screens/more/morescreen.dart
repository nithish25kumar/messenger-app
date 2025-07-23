import 'package:flutter/material.dart';
import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';

import '../../../domain/constants/appcolors.dart';

class Morescreen extends StatelessWidget {
  const Morescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.scaffolddark
            : AppColors.scaffoldlight,
        title: Uihelper.CustomText(
            text: "More",
            fontsize: 23,
            fontweight: FontWeight.bold,
            fontfamily: "bold",
            context: context),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                ),
                SizedBox(
                  width: 10,
                ),
                Uihelper.CustomText(
                    text: "Nithish Kumar ",
                    fontsize: 20,
                    fontweight: FontWeight.bold,
                    fontfamily: "bold",
                    context: context),
              ],
            ),
          ),
          Row(
            children: [TextButton(onPressed: () {}, child: Text("Account"))],
          )
        ],
      ),
    );
  }
}
