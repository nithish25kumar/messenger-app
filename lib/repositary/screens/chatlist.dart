import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/constants/appcolors.dart';
import 'chats/chatscreen.dart';

class ChatListScreen extends StatelessWidget {
  final User currentUser;

  const ChatListScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffolddark : AppColors.scaffoldlight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.scaffolddark : AppColors.scaffoldlight,
        title: const Text(
          'Chats',
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
                tileColor: isDark
                    ? AppColors.containerdarkmode.withOpacity(0.4)
                    : AppColors.containerlightmode,
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
                subtitle: Text(
                  userData['email'] ?? '',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.hintdarkmode
                        : AppColors.hintlightmode,
                    fontSize: 14,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Chatscreen(
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
