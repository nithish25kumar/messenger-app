import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chats/chatscreen.dart';

class ChatListScreen extends StatelessWidget {
  final User currentUser;
  const ChatListScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .snapshots(), // Or your own chat summary logic
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs.where(
          (doc) => doc['uid'] != currentUser.uid,
        );

        return ListView(
          children: users.map((doc) {
            final userData = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(userData['name'] ?? 'No Name'),
              subtitle: Text(userData['email'] ?? ''),
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
          }).toList(),
        );
      },
    );
  }
}
