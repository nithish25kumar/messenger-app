import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../domain/constants/appcolors.dart';
import '../widgets/Uihelper.dart';

class Chatscreen extends StatefulWidget {
  final User currentUser;
  final Map<String, dynamic> otherUser;

  const Chatscreen({
    super.key,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final TextEditingController messageController = TextEditingController();

  String getChatId() {
    final uid1 = widget.currentUser.uid;
    final uid2 = widget.otherUser['uid'];
    return uid1.compareTo(uid2) < 0 ? '$uid1\_$uid2' : '$uid2\_$uid1';
  }

  void sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final chatId = getChatId();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': widget.currentUser.uid,
      'receiverId': widget.otherUser['uid'],
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatId = getChatId();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffolddark : AppColors.scaffoldlight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.scaffolddark : AppColors.scaffoldlight,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUser['photoUrl'] != null
                  ? NetworkImage(widget.otherUser['photoUrl'])
                  : null,
              child: widget.otherUser['photoUrl'] == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Uihelper.CustomText(
              text: widget.otherUser['name'] ?? '',
              fontsize: 18,
              fontweight: FontWeight.bold,
              context: context,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 🟩 Chat Messages Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == widget.currentUser.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blueAccent
                              : Colors.grey.shade800, // darker for receiver
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Uihelper.CustomText(
                          text: msg['text'] ?? '',
                          fontsize: 14,
                          fontweight: FontWeight.w500,
                          context: context,
                          color: Colors.white, // white text for all messages
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

          // 🟩 Message Input Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.containerdarkmode
                          : AppColors.containerlightmode,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: messageController,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textdarkmode
                            : AppColors.textlightmode,
                      ),
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        hintStyle: TextStyle(
                          color: isDark
                              ? AppColors.hintdarkmode
                              : AppColors.hintlightmode,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
