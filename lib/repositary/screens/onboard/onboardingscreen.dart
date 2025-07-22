import 'package:flutter/material.dart';
import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';

class Onboardingscreen extends StatelessWidget {
  const Onboardingscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Uihelper.CustomImage(imgurl: "onboarding.png")],
      ),
    );
  }
}
