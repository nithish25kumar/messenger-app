import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messenger_app/repositary/screens/chats/chatscreen.dart';

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

  /* ---------------- FETCH CONTACTS ---------------- */

  void fetchContacts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUser.uid)
        .collection('contacts')
        .get();

    setState(() {
      contactList = snapshot.docs.map((e) => e.data()).toList();
    });
  }

  /* ---------------- SEARCH ---------------- */

  void searchByPhoneNumber(String phone) async {
    if (phone.isEmpty) {
      setState(() => searchedUser = null);
      return;
    }

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .get();

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      if (data['uid'] != widget.currentUser.uid) {
        setState(() => searchedUser = data);
      }
    } else {
      setState(() => searchedUser = null);
    }
  }

  /* ---------------- CONTACT TILE ---------------- */

  Widget buildContactTile(Map<String, dynamic> user) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF25D366), Color(0xFF128C7E)],
            ),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: user['photoUrl'] != null
                ? NetworkImage(user['photoUrl'])
                : null,
            child: user['photoUrl'] == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
        ),
        title: Text(
          user['name'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          user['phone'] ?? '',
          style: TextStyle(
            color: theme.hintColor,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
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
      ),
    );
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contacts",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),

      /* ---------------- BODY ---------------- */

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* -------- SEARCH GLASS BAR -------- */

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: theme.cardColor.withOpacity(.6),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.black.withOpacity(.05),
                ),
              ),
              child: TextField(
                controller: searchController,
                keyboardType: TextInputType.phone,
                onChanged: (v) => searchByPhoneNumber(v.trim()),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search by phone number",
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            searchController.clear();
                            setState(() => searchedUser = null);
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 18),

            /* -------- SEARCH RESULT -------- */

            if (searchedUser != null)
              buildContactTile(searchedUser!)
            else if (searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "No user found",
                  style: TextStyle(
                    color: theme.hintColor,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            /* -------- SECTION HEADER -------- */

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Your Contacts",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  contactList.length.toString(),
                  style: TextStyle(
                    color: theme.hintColor,
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),

            /* -------- CONTACT LIST -------- */

            Expanded(
              child: contactList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.people_outline,
                              size: 60, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            "No contacts yet",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          )
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 6),
                      itemCount: contactList.length,
                      itemBuilder: (_, i) => buildContactTile(contactList[i]),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
