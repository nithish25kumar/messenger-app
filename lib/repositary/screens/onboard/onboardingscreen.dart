import 'package:cloud_firestore/cloud_firestore.dart';
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
      // 🔁 Sign out from previous sessions to force account picker
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User cancelled sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Temporary sign-in to get UID
      UserCredential result =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = result.user;

      if (user != null) {
        final email = user.email;
        final uid = user.uid;

        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          // ✅ User exists → go to home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Bottomnavscreen()),
          );
        } else {
          // ❌ User doesn't exist → show message and sign out
          await FirebaseAuth.instance.signOut();
          await GoogleSignIn().signOut();
          Uihelper.showSnackBar(context, "No account found for ${email}");
        }
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
        automaticallyImplyLeading: false,
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
