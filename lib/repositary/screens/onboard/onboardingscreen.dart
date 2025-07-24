import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messenger_app/domain/constants/appcolors.dart';
import 'package:messenger_app/domain/constants/cubits/themecubit.dart';
import 'package:messenger_app/repositary/screens/bottomnav/bottomNavscreen.dart';
import 'package:messenger_app/repositary/screens/login/loginscreen.dart';
import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';

class Onboardingscreen extends StatelessWidget {
  const Onboardingscreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // Force logout from previous Google session
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (result.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Bottomnavscreen()),
        );
      }
    } catch (e) {
      Uihelper.showSnackBar(context, "Google Sign-In Failed: $e");
    }
  }

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
            icon: const Icon(Icons.dark_mode),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 30),
        child: Center(
          child: Column(
            children: [
              Uihelper.CustomImage(imgurl: "onboarding.png"),
              const SizedBox(height: 50),
              Uihelper.CustomText(
                text:
                    "Connect easily with \n your family and friends\n over countries",
                fontsize: 25,
                fontweight: FontWeight.bold,
                context: context,
              ),
              const SizedBox(height: 60),
              Uihelper.CustomButton(
                buttonnname: "Start Messaging",
                callback: () {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const Bottomnavscreen()),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => Loginscreen()),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              Uihelper.CustomButton(
                buttonnname: "Login with Google",
                callback: () => _signInWithGoogle(context),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
