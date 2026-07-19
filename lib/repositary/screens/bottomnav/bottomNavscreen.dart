import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:messenger_app/repositary/screens/contacts/contactscreen.dart';
import 'package:messenger_app/repositary/screens/more/morescreen.dart';
import '../chatlist.dart';

class Bottomnavscreen extends StatefulWidget {
  const Bottomnavscreen({super.key});

  @override
  State<Bottomnavscreen> createState() => _BottomnavscreenState();
}

class _BottomnavscreenState extends State<Bottomnavscreen> {
  int currentIndex = 0;
  late List<Widget> pages;
  late User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!;
    pages = [
      Contactscreen(currentUser: currentUser),
      ChatListScreen(currentUser: currentUser),
      Morescreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.05),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor:
                  Theme.of(context).primaryColor, // Active icon & text color
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Theme.of(context)
                  .primaryColor
                  .withOpacity(0.1), // Pill background
              color: Colors.grey[600], // Unselected icon color
              tabs: const [
                GButton(
                  icon: Icons.person_2_outlined,
                  text: 'Contacts',
                ),
                GButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  text: 'Chats',
                ),
                GButton(
                  icon: Icons.more_horiz,
                  text: 'More',
                ),
              ],
              selectedIndex: currentIndex,
              onTabChange: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
