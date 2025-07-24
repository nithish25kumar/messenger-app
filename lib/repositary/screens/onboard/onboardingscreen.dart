import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messenger_app/domain/constants/appcolors.dart';
import 'package:messenger_app/repositary/screens/bottomnav/bottomNavscreen.dart';
import 'package:messenger_app/repositary/screens/login/loginscreen.dart';
import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';

class Onboardingscreen extends StatelessWidget {
  const Onboardingscreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = result.user;

      if (user != null) {
        final email = user.email;
        final uid = user.uid;

        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Bottomnavscreen()),
          );
        } else {
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: Uihelper.CustomText(
            text: "Zynk-Messenger",
            fontsize: 25,
            fontweight: FontWeight.bold,
            fontfamily: "bold",
            context: context),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Uihelper.CustomImage(imgurl: "intro.png"),
              const SizedBox(height: 90),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Uihelper.CustomText(
                    text:
                        "Vibe, chat, repeat.\nStay close, no matter the coast 🌍",
                    fontsize: 22,
                    fontweight: FontWeight.bold,
                    context: context,
                  ),
                ],
              ),
              const SizedBox(height: 170),
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
              const SizedBox(height: 10),
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
