import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/constants/appcolors.dart';
import 'chats/chatscreen.dart';

class ChatListScreen extends StatelessWidget {
  final User currentUser;

  const ChatListScreen({super.key, required this.currentUser});

  String getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '$uid1\_$uid2' : '$uid2\_$uid1';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'My Chats',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs.where(
            (doc) => doc['uid'] != currentUser.uid,
          );

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            separatorBuilder: (context, index) => const Divider(),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final doc = users.elementAt(index);
              final userData = doc.data() as Map<String, dynamic>;

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                tileColor: Colors.lightGreenAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      isDark ? AppColors.iconlight : AppColors.icondarkmode,
                  child: Text(
                    userData['name'] != null && userData['name'].isNotEmpty
                        ? userData['name'][0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                title: Text(
                  userData['name'] ?? 'No Name',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textdarkmode
                        : AppColors.textlightmode,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(getChatId(currentUser.uid, userData['uid']))
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .limit(1)
                      .snapshots(),
                  builder: (context, messageSnapshot) {
                    if (!messageSnapshot.hasData ||
                        messageSnapshot.data!.docs.isEmpty) {
                      return Text(
                        'No messages yet',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.hintdarkmode
                              : AppColors.hintlightmode,
                          fontSize: 14,
                        ),
                      );
                    }

                    final lastMessage = messageSnapshot.data!.docs.first.data()
                        as Map<String, dynamic>;

                    return Text(
                      lastMessage['message'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.hintdarkmode
                            : AppColors.hintlightmode,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        currentUser: currentUser,
                        otherUser: userData,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
