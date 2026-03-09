import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:messenger_app/repositary/screens/bottomnav/bottomNavscreen.dart';
import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';

import '../../../blockchain/blockchain_service.dart';
import '../../../blockchain/crypto_service.dart';
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
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  void sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatId = getChatId(widget.currentUser.uid, widget.otherUser['uid']);

    final crypto = CryptoService();
    final key = crypto.generateKey();
    final encrypted = crypto.encryptMessage(message, key);

    final hash = crypto.hashMessage(encrypted['cipherText']);

    final lastMsg = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    String prevSignature = "";

    if (lastMsg.docs.isNotEmpty) {
      prevSignature = lastMsg.docs.first['signature'] ?? "";
    }

    final docRef = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': widget.currentUser.uid,
      'receiverId': widget.otherUser['uid'],
      'cipherText': encrypted['cipherText'],
      'iv': encrypted['iv'],
      'aesKey': encrypted['key'],
      'hash': hash,
      'signature': hash,
      'prevSignature': prevSignature,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'sent',
    });

    final blockchain = BlockchainService();

    await blockchain.storeMessageMeta(
      privateKey:
          "0x02c4a2ac966a3a596fab0f0ad9e5fad786393b80815ba067a8f927d73e5e4865",
      receiver: "0x9810808CdCA26f287e2560dd1c403A387697bCab",
      cid: docRef.id,
      signature: hash,
      prevSignature: prevSignature,
    );

    _messageController.clear();
  }

  void markMessagesAsSeen() async {
    final chatId = getChatId(widget.currentUser.uid, widget.otherUser['uid']);

    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: widget.currentUser.uid)
        .where('status', isNotEqualTo: 'seen')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'status': 'seen'});
    }
  }

  @override
  void initState() {
    super.initState();
    markMessagesAsSeen();
  }

  String formatTimestamp(Timestamp timestamp) {
    final dt = timestamp.toDate();
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  String decryptMessage(Map<String, dynamic> data) {
    try {
      final key = encrypt.Key.fromBase64(data['aesKey']);
      final iv = encrypt.IV.fromBase64(data['iv']);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      return encrypter.decrypt64(
        data['cipherText'],
        iv: iv,
      );
    } catch (_) {
      return "[Decryption failed]";
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatId = getChatId(widget.currentUser.uid, widget.otherUser['uid']);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration:
              const BoxDecoration(color: Color(0xFF25D366)), // WhatsApp green
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const Bottomnavscreen(),
              ),
            );
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                ),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: widget.otherUser['photoUrl'] != null
                    ? NetworkImage(widget.otherUser['photoUrl'])
                    : null,
                backgroundColor: Colors.grey.shade200,
                child: widget.otherUser['photoUrl'] == null
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.otherUser['name'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      "Start the conversation",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;

                    final isMe = data['senderId'] == widget.currentUser.uid;

                    final text = decryptMessage(data);

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                        constraints: const BoxConstraints(maxWidth: 270),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.buttonlightmode.withOpacity(.9)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              text,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['timestamp'] != null
                                  ? formatTimestamp(data['timestamp'])
                                  : '',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
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
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Uihelper.CustomMessageTextField(
                      controller: _messageController,
                      context: context,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded),
                      color: Colors.white,
                      onPressed: sendMessage,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
