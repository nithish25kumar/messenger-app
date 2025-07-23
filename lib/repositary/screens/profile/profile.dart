import 'package:flutter/material.dart';
import 'package:messenger_app/repositary/screens/bottomnav/bottomNavscreen.dart';
import 'package:messenger_app/repositary/screens/otpscreen/otpscreen.dart';
import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';

import '../../../domain/constants/appcolors.dart';

class Profile extends StatelessWidget {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.scaffolddark
            : AppColors.scaffoldlight,
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => Otpscreen()));
            },
            icon: Icon(Icons.arrow_back_ios_new)),
        title: Uihelper.CustomText(
            text: "Your Profile",
            fontsize: 23,
            fontweight: FontWeight.bold,
            fontfamily: "bold",
            context: context),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Theme.of(context).brightness == Brightness.dark
                ? Uihelper.CustomImage(imgurl: "darkprofile.png")
                : Uihelper.CustomImage(imgurl: "lightprofile.png"),
            SizedBox(
              height: 30,
            ),
            Uihelper.CustomTextField(
                controller: firstNameController,
                text: "First Name (Required)",
                textinputtype: TextInputType.text,
                context: context,
                icondata: Icons.person),
            SizedBox(
              height: 10,
            ),
            Uihelper.CustomTextField(
                controller: lastNameController,
                text: "Last Name (Required)",
                textinputtype: TextInputType.text,
                context: context,
                icondata: Icons.person)
          ],
        ),
      ),
      floatingActionButton: Uihelper.CustomButton(
          buttonnname: "Save",
          callback: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => Bottomnavscreen()));
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
