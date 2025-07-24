import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../more/morescreen.dart';
import '../widgets/Uihelper.dart';

class Creatorinfoscreen extends StatelessWidget {
  const Creatorinfoscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Uihelper.CustomText(
            text: "Creator Screen",
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              CircleAvatar(
                  radius: 90,
                  backgroundImage: AssetImage("assets/images/img_1.png")),
              const SizedBox(height: 15),
              const Text(
                'Nithishkumar K',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'VIT Vellore',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  launchUrl(Uri.parse(
                      'https://www.linkedin.com/in/nithish-kumar-9b29b3287/'));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      FontAwesomeIcons.linkedin,
                      size: 20,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "LinkedIn",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
