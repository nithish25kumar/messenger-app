import 'package:flutter/material.dart';
import 'package:messenger_app/repositary/screens/chats/chatscreen.dart';
import 'package:messenger_app/repositary/screens/contacts/contactscreen.dart';
import 'package:messenger_app/repositary/screens/more/morescreen.dart';

class Bottomnavscreen extends StatefulWidget {
  const Bottomnavscreen({super.key});

  @override
  State<Bottomnavscreen> createState() => _BottomnavscreenState();
}

class _BottomnavscreenState extends State<Bottomnavscreen> {
  int currentIndex = 0;
  List<Widget> pages = [Contactscreen(), Chatscreen(), Morescreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined), label: "Contacts"),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "More")
        ],
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
      ),
      body: IndexedStack(
        children: pages,
        index: currentIndex,
      ),
    );
  }
}
