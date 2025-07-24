import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messenger_app/repositary/screens/chats/chatscreen.dart';
import 'package:messenger_app/repositary/screens/onboard/onboardingscreen.dart';
import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';
import '../../../domain/constants/appcolors.dart';

class Contactscreen extends StatefulWidget {
  final User currentUser;

  const Contactscreen({super.key, required this.currentUser});

  @override
  State<Contactscreen> createState() => _ContactscreenState();
}

class _ContactscreenState extends State<Contactscreen> {
  final TextEditingController searchController = TextEditingController();
  Map<String, dynamic>? searchedUser;
  List<Map<String, dynamic>> contactList = [];

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  void fetchContacts() async {
    final contactsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUser.uid)
        .collection('contacts')
        .get();

    final contacts = contactsSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    setState(() {
      contactList = contacts;
    });
  }

  void addToContacts(Map<String, dynamic> user) async {
    final contactRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUser.uid)
        .collection('contacts')
        .doc(user['uid']);

    final doc = await contactRef.get();
    if (!doc.exists) {
      await contactRef.set(user);
      fetchContacts();
    }
  }

  void searchByPhoneNumber(String phone) async {
    if (phone.isEmpty) {
      setState(() => searchedUser = null);
      return;
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final userData = querySnapshot.docs.first.data();
      if (userData['uid'] != widget.currentUser.uid) {
        setState(() => searchedUser = userData);
      } else {
        setState(() => searchedUser = null); // avoid showing self
      }
    } else {
      setState(() => searchedUser = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Uihelper.CustomText(
          text: "Contacts",
          fontsize: 25,
          fontweight: FontWeight.bold,
          fontfamily: "bold",
          context: context,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.contact_page_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Uihelper.CustomTextField(
              controller: searchController,
              text: "Enter Phone Number",
              textinputtype: TextInputType.phone,
              context: context,
              icondata: Icons.search,
              onChanged: (value) => searchByPhoneNumber(value.trim()),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() => searchedUser = null);
                      },
                    )
                  : null,
            ),
            const SizedBox(height: 10),

            if (searchedUser != null)
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: searchedUser!['photoUrl'] != null
                      ? NetworkImage(searchedUser!['photoUrl'])
                      : null,
                  child: searchedUser!['photoUrl'] == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                  radius: 25,
                ),
                title: Text(searchedUser!['name'] ?? ''),
                subtitle: Text(searchedUser!['phone'] ?? ''),
                onTap: () {
                  addToContacts(searchedUser!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        currentUser: widget.currentUser,
                        otherUser: searchedUser!,
                      ),
                    ),
                  );
                },
              )
            else if (searchController.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child:
                    Text("No user found", style: TextStyle(color: Colors.grey)),
              ),

            const SizedBox(height: 20),
            Uihelper.CustomText(
              text: "Your Contacts",
              fontsize: 18,
              fontweight: FontWeight.bold,
              context: context,
            ),
            const SizedBox(height: 10),

            // Contact List
            Expanded(
              child: contactList.isEmpty
                  ? const Text("No contacts yet",
                      style: TextStyle(color: Colors.grey))
                  : ListView.builder(
                      itemCount: contactList.length,
                      itemBuilder: (context, index) {
                        final user = contactList[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user['photoUrl'] != null
                                ? NetworkImage(user['photoUrl'])
                                : null,
                            child: user['photoUrl'] == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Text(user['name'] ?? ''),
                          subtitle: Text(user['phone'] ?? ''),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  currentUser: widget.currentUser,
                                  otherUser: user,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
