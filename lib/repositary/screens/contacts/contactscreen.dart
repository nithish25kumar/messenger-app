import 'dart:async';
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

class _ContactscreenState extends State<Contactscreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  Map<String, dynamic>? searchedUser;
  List<Map<String, dynamic>> contactList = [];
  bool isSearching = false;
  bool isLoadingContacts = true;
  Timer? _debounce;
  late final TabController _tabController;

  static const Color _accentStart = Color(0xFF25D366);
  static const Color _accentEnd = Color(0xFF128C7E);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchContacts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchContacts() async {
    setState(() => isLoadingContacts = true);
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUser.uid)
        .collection('contacts')
        .get();

    setState(() {
      contactList = snapshot.docs.map((e) => e.data()).toList();
      isLoadingContacts = false;
    });
  }

  void onSearchChanged(String phone) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      searchByPhoneNumber(phone.trim());
    });
  }

  Future<void> searchByPhoneNumber(String phone) async {
    if (phone.isEmpty) {
      setState(() {
        searchedUser = null;
        isSearching = false;
      });
      return;
    }

    setState(() => isSearching = true);

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .get();

    if (!mounted) return;

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      if (data['uid'] != widget.currentUser.uid) {
        setState(() {
          searchedUser = data;
          isSearching = false;
        });
      } else {
        setState(() {
          searchedUser = null;
          isSearching = false;
        });
      }
    } else {
      setState(() {
        searchedUser = null;
        isSearching = false;
      });
    }
  }

  bool _isAlreadyContact(String uid) {
    return contactList.any((c) => c['uid'] == uid);
  }

  Future<void> addContact(Map<String, dynamic> user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUser.uid)
        .collection('contacts')
        .doc(user['uid'])
        .set(user);

    setState(() {
      contactList.insert(0, user);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user['name'] ?? 'Contact'} added'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> removeContact(Map<String, dynamic> user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUser.uid)
        .collection('contacts')
        .doc(user['uid'])
        .delete();

    setState(() {
      contactList.removeWhere((c) => c['uid'] == user['uid']);
    });
  }

  Widget buildContactTile(Map<String, dynamic> user,
      {bool isSearchResult = false, bool isDiscover = false}) {
    final theme = Theme.of(context);
    final alreadyContact = _isAlreadyContact(user['uid']);
    final showAddButton = isSearchResult || isDiscover;

    final tile = Container(
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
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [_accentStart, _accentEnd],
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
        trailing: showAddButton
            ? (alreadyContact
                ? Icon(Icons.check_circle_rounded, color: _accentStart)
                : IconButton(
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    color: _accentStart,
                    onPressed: () => addContact(user),
                  ))
            : const Icon(Icons.chevron_right_rounded),
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

    if (showAddButton) return tile;

    return Dismissible(
      key: Key(user['uid']),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => removeContact(user),
      child: tile,
    );
  }

  Widget _buildContactsTab() {
    return isLoadingContacts
        ? const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(_accentStart),
            ),
          )
        : contactList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.people_outline, size: 60, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      "No contacts yet",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    )
                  ],
                ),
              )
            : RefreshIndicator(
                color: _accentStart,
                onRefresh: fetchContacts,
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 6),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: contactList.length,
                  itemBuilder: (_, i) => buildContactTile(contactList[i]),
                ),
              );
  }

  Widget _buildDiscoverTab() {
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Couldn't load users",
              style: TextStyle(color: theme.hintColor),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(_accentStart),
            ),
          );
        }

        final allUsers = snapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .where((u) => u['uid'] != widget.currentUser.uid)
            .toList();

        if (allUsers.isEmpty) {
          return Center(
            child: Text(
              "No other users on the app yet",
              style: TextStyle(color: theme.hintColor, fontSize: 15),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 6),
          itemCount: allUsers.length,
          itemBuilder: (_, i) =>
              buildContactTile(allUsers[i], isDiscover: true),
        );
      },
    );
  }

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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Container(
              height: 52,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.cardColor.withOpacity(.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: const LinearGradient(
                    colors: [_accentStart, _accentEnd],
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.zero,
                labelColor: Colors.white,
                unselectedLabelColor: theme.hintColor,
                labelStyle: const TextStyle(
                    fontSize: 15.5, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(
                    fontSize: 15.5, fontWeight: FontWeight.w600),
                dividerColor: Colors.transparent,
                splashBorderRadius: BorderRadius.circular(13),
                tabs: [
                  Tab(text: 'Contacts (${contactList.length})'),
                  const Tab(text: 'Discover'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildContactsTab(),
                  _buildDiscoverTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
