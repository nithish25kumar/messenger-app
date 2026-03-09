// Improved UI for ChatListScreen
// Added modern chat tiles, rounded containers, better spacing, shadows,
// profile avatar support, last message preview card, and smooth visuals.

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Chats',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
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

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final doc = users.elementAt(index);
              final userData = doc.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                  // PROFILE AVATAR
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: userData['photoUrl'] != null
                        ? NetworkImage(userData['photoUrl'])
                        : null,
                    backgroundColor:
                        userData['photoUrl'] != null ? null : Colors.blueGrey,
                    child: userData['photoUrl'] == null
                        ? Text(
                            userData['name'] != null &&
                                    userData['name'].isNotEmpty
                                ? userData['name'][0].toUpperCase()
                                : '?',
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          )
                        : null,
                  ),

                  title: Text(
                    userData['name'] ?? 'No Name',
                    style: TextStyle(
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
                    builder: (context, msgSnap) {
                      if (!msgSnap.hasData || msgSnap.data!.docs.isEmpty) {
                        return Text(
                          'No messages yet',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        );
                      }

                      final lastMessage = msgSnap.data!.docs.first.data()
                          as Map<String, dynamic>;

                      return Text(
                        lastMessage['message'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      );
                    },
                  ),

                  trailing: Icon(
                    Icons.chevron_right,
                    size: 28,
                    color: Colors.grey.shade500,
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
