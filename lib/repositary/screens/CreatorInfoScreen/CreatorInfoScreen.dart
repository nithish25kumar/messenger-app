import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/Uihelper.dart';

class Creatorinfoscreen extends StatelessWidget {
  const Creatorinfoscreen({super.key});

  Future<void> _launchLinkedIn() async {
    final url =
        Uri.parse('https://www.linkedin.com/in/nithish-kumar-9b29b3287/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Uihelper.CustomText(
          text: "Creator Info",
          fontsize: 23,
          fontweight: FontWeight.bold,
          fontfamily: "bold",
          context: context,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const CircleAvatar(
                radius: 90,
                backgroundImage: AssetImage("assets/images/img_1.png"),
              ),
              const SizedBox(height: 15),
              Text(
                'Nithishkumar K',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'VIT Vellore',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _launchLinkedIn,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      FontAwesomeIcons.linkedin,
                      size: 20,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "LinkedIn",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
