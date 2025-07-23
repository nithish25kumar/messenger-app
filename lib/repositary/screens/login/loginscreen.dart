import 'package:flutter/material.dart';
import 'package:messenger_app/repositary/screens/onboard/onboardingscreen.dart';
import 'package:messenger_app/repositary/screens/otpscreen/otpscreen.dart';
import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';

import '../../../domain/constants/appcolors.dart';

class Loginscreen extends StatelessWidget {
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.scaffolddark
            : AppColors.scaffoldlight,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => Onboardingscreen()));
            },
            icon: Icon(Icons.arrow_back_ios_new)),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 100,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Uihelper.CustomText(
                    text: "Enter Your Phone Number",
                    fontsize: 26,
                    fontweight: FontWeight.bold,
                    context: context),
                SizedBox(
                  height: 20,
                ),
                Uihelper.CustomText(
                    text: "Please confirm your country code and enter",
                    fontsize: 15,
                    context: context),
                Uihelper.CustomText(
                    text: "your phone number", fontsize: 15, context: context),
                SizedBox(
                  height: 50,
                ),
                Uihelper.CustomTextField(
                    controller: phoneController,
                    text: 'Phone Number',
                    textinputtype: TextInputType.number,
                    context: context,
                    icondata: Icons.phone),
                SizedBox(
                  height: 350,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Uihelper.CustomButton(
          buttonnname: "Continue",
          callback: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => Otpscreen()));
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
