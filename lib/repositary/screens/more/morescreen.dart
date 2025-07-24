import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger_app/repositary/screens/onboard/onboardingscreen.dart';
import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';

import '../../../domain/constants/appcolors.dart';

class Morescreen extends StatefulWidget {
  const Morescreen({super.key});

  @override
  State<Morescreen> createState() => _MorescreenState();
}

class _MorescreenState extends State<Morescreen> {
  final List<Map<String, dynamic>> arrMore = [
    {"icon": Icons.person, "txt": "Account"},
    {"icon": Icons.chat_sharp, "txt": "Chats"},
    {"icon": Icons.sunny, "txt": "Appearance"},
    {"icon": Icons.notifications_active, "txt": "Notifications"},
    {"icon": Icons.privacy_tip, "txt": "Privacy"},
    {"icon": Icons.folder, "txt": "Data Usage"},
    {"icon": Icons.help, "txt": "Help"},
    {"icon": Icons.mail, "txt": "Invite Your Friends"},
  ];

  String name = "";
  String phone = "";
  String profileUrl = "";

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          name = data['name'] ?? 'Unknown';
          phone = data['phone'] ?? '';
          profileUrl = data['profileUrl'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.scaffolddark : AppColors.scaffoldlight,
        title: Uihelper.CustomText(
          text: "More",
          fontsize: 23,
          fontweight: FontWeight.bold,
          fontfamily: "bold",
          context: context,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: profileUrl.isNotEmpty
                      ? NetworkImage(profileUrl)
                      : AssetImage(isDark
                          ? "assets/images/darkprofile.png"
                          : "assets/images/lightprofile.png") as ImageProvider,
                ),
                title: Uihelper.CustomText(
                  text: name,
                  fontsize: 16,
                  fontweight: FontWeight.bold,
                  context: context,
                ),
                subtitle: Uihelper.CustomText(
                  text: phone,
                  fontsize: 12,
                  context: context,
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {},
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: arrMore.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = arrMore[index];
                    return InkWell(
                      onTap: () {
                        // TODO: Add navigation for each option
                      },
                      child: ListTile(
                        leading: Icon(item["icon"] as IconData),
                        title: Uihelper.CustomText(
                          text: item["txt"].toString(),
                          fontsize: 14,
                          fontweight: FontWeight.w500,
                          context: context,
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.logout),
                label: Text("Logout"),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => Onboardingscreen()));
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
