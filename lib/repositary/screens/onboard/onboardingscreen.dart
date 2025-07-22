import 'package:flutter/material.dart';
import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';

class Onboardingscreen extends StatelessWidget {
  const Onboardingscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
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
                  context: context),
              SizedBox(
                height: 180,
              ),
              Uihelper.CustomButton(
                  buttonnname: "StartMessaging", callback: () {})
            ],
          ),
        ),
      ),
    );
  }
}
