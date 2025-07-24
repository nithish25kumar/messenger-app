import 'package:flutter/material.dart';

import '../more/morescreen.dart';
import '../widgets/Uihelper.dart';

class Privacyscreen extends StatelessWidget {
  const Privacyscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Uihelper.CustomText(
            text: "Privacy Policy",
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Uihelper.CustomText(
                text: '''

1. Introduction
Zynk Messenger respects your privacy and is committed to protecting your data.

2. Information We Collect
We collect your name, phone number, email, and profile image to create and manage your account.

3. Messaging Data
Messages shared in chats are stored securely and privately.

4. Contacts Access
We access your contact list only to show you which friends are on Zynk. We do not store your contact data on our servers.

5. Usage Data
We may collect anonymous data on app usage to improve features and performance.

6. Data Security
All messages and user data are encrypted and stored securely using Firebase services.

7. Third-Party Services
We use Firebase Authentication, Firestore, and Cloud Messaging which may collect some information independently.

8. No Data Selling
We never sell or trade your personal data to advertisers or third-party companies.

9. Data Sharing
Your data may be shared with legal authorities if required by law or to protect users.

10. Changes to Policy
Any updates to this Privacy Policy will be posted in-app with the latest revision date.

11. Contact Us
If you have questions or concerns, email us at support@zynkmessenger.app
  ''',
                fontsize: 14,
                context: context,
              )
            ],
          ),
        ),
      ),
    );
  }
}
