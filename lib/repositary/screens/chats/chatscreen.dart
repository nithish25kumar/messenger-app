import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger_app/repositary/screens/bottomnav/bottomNavscreen.dart';
import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';
import '../../../domain/constants/appcolors.dart';

class ChatScreen extends StatefulWidget {
  final User currentUser;
  final Map<String, dynamic> otherUser;

  const ChatScreen({
    super.key,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  String getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '$uid1\_$uid2' : '$uid2\_$uid1';
  }

  void sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatId = getChatId(widget.currentUser.uid, widget.otherUser['uid']);

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': widget.currentUser.uid,
      'receiverId': widget.otherUser['uid'],
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'sent',
    });

    _messageController.clear();
  }

  void markMessagesAsSeen() async {
    final chatId = getChatId(widget.currentUser.uid, widget.otherUser['uid']);

    final messagesSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: widget.currentUser.uid)
        .where('status', isNotEqualTo: 'seen')
        .get();

    for (var doc in messagesSnapshot.docs) {
      await doc.reference.update({'status': 'seen'});
    }
  }

  @override
  void initState() {
    super.initState();
    markMessagesAsSeen();
  }

  String formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final chatId = getChatId(widget.currentUser.uid, widget.otherUser['uid']);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.buttonlightmode,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const Bottomnavscreen()));
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.otherUser['photoUrl'] != null
                  ? NetworkImage(widget.otherUser['photoUrl'])
                  : null,
              backgroundColor: Colors.grey[300],
              child: widget.otherUser['photoUrl'] == null
                  ? const Icon(Icons.person, color: Colors.black)
                  : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUser['name'] ?? 'Unknown',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Uihelper.CustomText(
                      text: "Start the conversation!",
                      fontsize: 16,
                      context: context,
                      fontweight: FontWeight.w500,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == widget.currentUser.uid;

                    Icon? statusIcon;
                    if (isMe) {
                      final status = data['status'];
                      if (status == 'sent') {
                        statusIcon = const Icon(Icons.check, size: 16);
                      } else if (status == 'seen') {
                        statusIcon = const Icon(Icons.done_all,
                            size: 16, color: Colors.blue);
                      } else {
                        statusIcon = const Icon(Icons.done_all, size: 16);
                      }
                    }

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        constraints: const BoxConstraints(maxWidth: 250),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.buttonlightmode.withOpacity(0.85)
                              : AppColors.containerlightmode,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Uihelper.CustomText(
                              text: data['message'] ?? '',
                              fontsize: 15,
                              context: context,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  data['timestamp'] != null
                                      ? formatTimestamp(data['timestamp'])
                                      : '',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (statusIcon != null) ...[
                                  const SizedBox(width: 4),
                                  statusIcon,
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Uihelper.CustomMessageTextField(
                    controller: _messageController,
                    context: context,
                  ),
                ),
                const SizedBox(width: 8),
                Uihelper.CustomSendButton(
                  context: context,
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
