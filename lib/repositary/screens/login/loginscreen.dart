import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messenger_app/repositary/screens/bottomnav/bottomNavscreen.dart';

import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';
import '../../../domain/constants/appcolors.dart';
import '../onboard/onboardingscreen.dart';

class Loginscreen extends StatefulWidget {
  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  Future<void> handleGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      await googleSignIn.signOut(); // Force account picker
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        Uihelper.showSnackBar(context, "Google sign-in failed");
        setState(() => isLoading = false);
        return;
      }

      final phoneNumber = phoneController.text.trim();
      if (phoneNumber.isEmpty) {
        Uihelper.showSnackBar(context, "Please enter phone number");
        setState(() => isLoading = false);
        return;
      }

      // 🔒 Check if phone number is already used by another user
      final phoneQuery = await _firestore
          .collection("users")
          .where("phone", isEqualTo: phoneNumber)
          .get();

      if (phoneQuery.docs.isNotEmpty && phoneQuery.docs.first.id != user.uid) {
        Uihelper.showSnackBar(
            context, "Phone number is already linked with another account");
        setState(() => isLoading = false);
        return;
      }

      // 🔒 Check if email is already registered (optional if Firebase Auth handles it)
      final existingDoc =
          await _firestore.collection("users").doc(user.uid).get();
      if (existingDoc.exists) {
        Uihelper.showSnackBar(context,
            "Email is already linked. Please use a different Google account.");
        setState(() => isLoading = false);
        return;
      }

      // ✅ Save new user
      await _firestore.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "email": user.email,
        "name": user.displayName,
        "phone": phoneNumber,
        "photoUrl": user.photoURL,
        "createdAt": Timestamp.now(),
      });

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => Bottomnavscreen()));
    } catch (e) {
      Uihelper.showSnackBar(context, "Error: ${e.toString()}");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.scaffolddark : AppColors.scaffoldlight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => Onboardingscreen())),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Uihelper.CustomText(
                    text: "Sign in with Google",
                    fontsize: 26,
                    fontweight: FontWeight.bold,
                    context: context),
                SizedBox(height: 20),
                Uihelper.CustomTextField(
                  controller: phoneController,
                  text: 'Phone Number',
                  textinputtype: TextInputType.phone,
                  context: context,
                  icondata: Icons.phone,
                  onChanged: (value) {},
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: isLoading
          ? CircularProgressIndicator()
          : Uihelper.CustomButton(
              buttonnname: "Continue with Google",
              callback: handleGoogleSignIn,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
