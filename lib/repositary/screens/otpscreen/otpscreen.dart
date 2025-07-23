import 'package:flutter/material.dart';
import 'package:messenger_app/repositary/screens/login/loginscreen.dart';
import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';
import 'package:pinput/pinput.dart';
import '../../../domain/constants/appcolors.dart';

class Otpscreen extends StatefulWidget {
  @override
  _OtpscreenState createState() => _OtpscreenState();
}

class _OtpscreenState extends State<Otpscreen> {
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.otpdarkmode
          : AppColors.otplightmode,
      borderRadius: BorderRadius.circular(7),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.otpdarkmode
            : AppColors.otplightmode,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.scaffolddark
            : AppColors.scaffoldlight,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => Loginscreen()),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Uihelper.CustomText(
              text: "Enter Code",
              fontsize: 25,
              fontweight: FontWeight.bold,
              fontfamily: 'bold',
              context: context,
            ),
            SizedBox(height: 20),
            Uihelper.CustomText(
              text: "We have sent you an SMS with the code",
              fontsize: 15,
              fontweight: FontWeight.bold,
              context: context,
            ),
            Uihelper.CustomText(
              text: "to your number",
              fontsize: 15,
              fontweight: FontWeight.bold,
              context: context,
            ),
            SizedBox(height: 20),
            Pinput(
              controller: otpController,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              length: 4,
            ),
          ],
        ),
      ),
    );
  }
}
