import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger_app/domain/constants/appcolors.dart';
import 'package:messenger_app/domain/constants/cubits/themecubit.dart';
import 'package:messenger_app/repositary/screens/login/loginscreen.dart';
import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';

class Onboardingscreen extends StatelessWidget {
  const Onboardingscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.scaffolddark
            : AppColors.scaffoldlight,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                BlocProvider.of<Themecubit>(context).toggleTheme();
              },
              icon: Icon(Icons.dark_mode))
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Uihelper.CustomImage(
                  imgurl: "onboarding.png",
                ),
                SizedBox(
                  height: 50,
                ),
                Uihelper.CustomText(
                    text:
                        "Connect easily with \n your family and friends\n over countries",
                    fontsize: 25,
                    fontweight: FontWeight.bold,
                    context: context),
                SizedBox(
                  height: 180,
                ),
                Uihelper.CustomButton(
                    buttonnname: "StartMessaging",
                    callback: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => Loginscreen()));
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
