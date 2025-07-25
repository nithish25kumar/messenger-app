import 'package:flutter/material.dart';

import '../more/morescreen.dart';
import '../widgets/Uihelper.dart';

class Invitefriendsscreen extends StatelessWidget {
  const Invitefriendsscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Uihelper.CustomText(
            text: "Account Screen",
            fontsize: 25,
            fontweight: FontWeight.bold,
            fontfamily: "bold",
            context: context),
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => Morescreen()));
            },
            icon: Icon(Icons.arrow_back_ios_new)),
      ),
    );
  }
}
