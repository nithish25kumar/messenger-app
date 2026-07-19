import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger_app/repositary/screens/CreatorInfoScreen/CreatorInfoScreen.dart';

import 'package:messenger_app/repositary/screens/PrivacyScreen/PrivacyScreen.dart';
import 'package:messenger_app/repositary/screens/onboard/onboardingscreen.dart';
import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../domain/constants/appcolors.dart';

class Morescreen extends StatefulWidget {
  const Morescreen({super.key});

  @override
  State<Morescreen> createState() => _MorescreenState();
}

class _MorescreenState extends State<Morescreen> {
  final List<Map<String, dynamic>> arrMore = [
    {"icon": Icons.notifications_none_rounded, "txt": "Notifications"},
    {"icon": Icons.help_outline_rounded, "txt": "Help & Support"},
    {"icon": Icons.developer_board, "txt": "Creator Info"},
    {"icon": Icons.privacy_tip_outlined, "txt": "Privacy"},
  ];

  String name = "";
  String phone = "";
  String profileUrl = "";
  bool isLoadingProfile = true;
  String appVersion = "";

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    fetchAppVersion();
  }

  Future<void> fetchUserDetails() async {
    setState(() => isLoadingProfile = true);
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
    if (mounted) setState(() => isLoadingProfile = false);
  }

  Future<void> fetchAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => appVersion = "v${info.version} (${info.buildNumber})");
      }
    } catch (_) {
      // package_info_plus not set up yet — safe to ignore.
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Log out?",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          "You'll need to sign in again to access your chats.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Log out"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Onboardingscreen()),
        );
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
        child: RefreshIndicator(
          onRefresh: fetchUserDetails,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              const SizedBox(height: 10),
              isLoadingProfile
                  ? _buildProfileSkeleton()
                  : ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: profileUrl.isNotEmpty
                            ? NetworkImage(profileUrl)
                            : AssetImage(isDark
                                    ? "assets/images/darkprofile.png"
                                    : "assets/images/lightprofile.png")
                                as ImageProvider,
                      ),
                      title: Uihelper.CustomText(
                        text: name.isNotEmpty ? name : "Unknown",
                        fontsize: 16,
                        fontweight: FontWeight.bold,
                        context: context,
                      ),
                      subtitle: Uihelper.CustomText(
                        text: phone,
                        fontsize: 12,
                        context: context,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        // TODO: hook up to your Edit Profile screen
                      },
                    ),
              const SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: arrMore.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = arrMore[index];
                  return InkWell(
                    onTap: () {
                      switch (item["txt"]) {
                        case "Creator Info":
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => Creatorinfoscreen()));
                          break;
                        case "Privacy":
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => Privacyscreen()));
                          break;
                        case "Notifications":
                        case "Help & Support":
                          // TODO: wire these up once those screens exist
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${item["txt"]} — coming soon"),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          break;
                      }
                    },
                    child: ListTile(
                      leading: Icon(item["icon"] as IconData),
                      title: Uihelper.CustomText(
                        text: item["txt"].toString(),
                        fontsize: 14,
                        fontweight: FontWeight.w500,
                        context: context,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                onPressed: _confirmLogout,
              ),
              const SizedBox(height: 14),
              if (appVersion.isNotEmpty)
                Center(
                  child: Text(
                    appVersion,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSkeleton() {
    return const ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Color(0x22000000),
      ),
      title: SizedBox(
        height: 14,
        width: 100,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Color(0x22000000)),
        ),
      ),
    );
  }
}
