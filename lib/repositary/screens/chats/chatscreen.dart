import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:messenger_app/repositary/screens/bottomnav/bottomNavscreen.dart';

import '../../../blockchain/blockchain_service.dart';
import '../../../blockchain/crypto_service.dart';

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

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final CryptoService _crypto = CryptoService();

  // Color Palette calibrated for White light mode backgrounds
  static const Color surfaceWhite = Colors.white;
  static const Color accentNeon =
      Color(0xFFFF2D55); // Premium vibrant action pink/red
  static const Color bubbleMe =
      Color(0xFFFEEBF0); // Soft accent tint for sender bubble
  static const Color bubbleOther =
      Color(0xFFF2F4F7); // Minimal light gray for recipient bubble
  static const Color textMain = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF6C7075);
  static const Color verifiedGreen = Color(0xFF12B76A);

  // ---- New feature state ----
  Map<String, dynamic>? _replyingTo; // {'id', 'senderId', 'text'}
  bool _isSearching = false;
  String _searchQuery = '';
  Timer? _typingDebounce;
  bool _iAmTyping = false;

  String get chatId =>
      getChatId(widget.currentUser.uid, widget.otherUser['uid']);

  String getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  String _capitalizeFirst(String? text) {
    if (text == null || text.trim().isEmpty) return '';
    final trimmed = text.trim();
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    markMessagesAsSeen();
    _setPresence(true);
    _messageController.addListener(_handleTypingChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.removeListener(_handleTypingChange);
    _setTyping(false);
    _setPresence(false);
    _typingDebounce?.cancel();
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setPresence(true);
    } else {
      _setPresence(false);
    }
  }

  // ---------------- Presence ----------------

  void _setPresence(bool online) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUser.uid)
        .set({
      'isOnline': online,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ---------------- Typing indicator ----------------

  void _handleTypingChange() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText && !_iAmTyping) {
      _setTyping(true);
    }
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(seconds: 2), () {
      _setTyping(false);
    });
  }

  void _setTyping(bool typing) {
    if (_iAmTyping == typing) return;
    _iAmTyping = typing;
    FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'typing': {widget.currentUser.uid: typing},
    }, SetOptions(merge: true));
  }

  // ---------------- Sending / receiving ----------------

  void sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final crypto = _crypto;
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

    final replyTo = _replyingTo;

    _messageController.clear();
    setState(() => _replyingTo = null);
    _setTyping(false);

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
      'deleted': false,
      if (replyTo != null) 'replyToId': replyTo['id'],
      if (replyTo != null) 'replyToSenderId': replyTo['senderId'],
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
  }

  void markMessagesAsSeen() async {
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

  Future<void> deleteMessage(String docId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(docId)
        .update({'deleted': true});
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

  // ---------------- Blockchain / integrity verification ----------------

  void _showVerifySheet(Map<String, dynamic> data) {
    final recomputedHash = _crypto.hashMessage(data['cipherText']);
    final isIntact = recomputedHash == data['hash'];

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isIntact
                        ? Icons.verified_rounded
                        : Icons.warning_amber_rounded,
                    color: isIntact ? verifiedGreen : accentNeon,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isIntact ? 'Message verified' : 'Integrity check failed',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textMain),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isIntact
                    ? 'The recomputed hash matches the stored signature. This message has not been altered.'
                    : 'The recomputed hash does not match the stored signature. This message may have been tampered with.',
                style: const TextStyle(fontSize: 13, color: textSecondary),
              ),
              const SizedBox(height: 16),
              _verifyRow('Signature', data['signature']),
              _verifyRow(
                  'Previous signature',
                  (data['prevSignature'] ?? '').toString().isEmpty
                      ? 'genesis'
                      : data['prevSignature']),
              _verifyRow('Recomputed hash', recomputedHash),
            ],
          ),
        );
      },
    );
  }

  Widget _verifyRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textSecondary)),
          const SizedBox(height: 2),
          Text(
            value ?? '',
            style: const TextStyle(
                fontSize: 12.5, color: textMain, fontFamily: 'monospace'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ---------------- Message long-press actions ----------------

  void _showMessageActions({
    required String docId,
    required Map<String, dynamic> data,
    required String decrypted,
    required bool isMe,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.reply_rounded, color: textMain),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _replyingTo = {
                      'id': docId,
                      'senderId': data['senderId'],
                      'text': decrypted,
                    };
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: textMain),
                title: const Text('Copy text'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: decrypted));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.verified_outlined, color: textMain),
                title: const Text('Verify message'),
                onTap: () {
                  Navigator.pop(context);
                  _showVerifySheet(data);
                },
              ),
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded,
                      color: accentNeon),
                  title: const Text('Delete for everyone',
                      style: TextStyle(color: accentNeon)),
                  onTap: () {
                    Navigator.pop(context);
                    deleteMessage(docId);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- Date separators ----------------

  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: surfaceWhite,
        cardColor: bubbleOther,
      ),
      child: Scaffold(
        appBar: _isSearching ? _buildSearchAppBar() : _buildDefaultAppBar(),
        body: Column(
          children: [
            _buildTypingBanner(),
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
                    return const Center(
                        child: CircularProgressIndicator(color: accentNeon));
                  }

                  final allDocs = snapshot.data!.docs;

                  if (allDocs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded,
                              color: textSecondary, size: 36),
                          SizedBox(height: 12),
                          Text(
                            "Secure connection initiated.",
                            style: TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }

                  // Pre-decrypt for lookup (replies) and optional search filter.
                  final decryptedById = <String, String>{};
                  for (final doc in allDocs) {
                    final data = doc.data() as Map<String, dynamic>;
                    decryptedById[doc.id] =
                        data['deleted'] == true ? '' : decryptMessage(data);
                  }

                  var visibleDocs = allDocs;
                  if (_isSearching && _searchQuery.trim().isNotEmpty) {
                    final q = _searchQuery.trim().toLowerCase();
                    visibleDocs = allDocs.where((doc) {
                      final text = decryptedById[doc.id] ?? '';
                      return text.toLowerCase().contains(q);
                    }).toList();
                  }

                  if (visibleDocs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No matching messages",
                        style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    );
                  }

                  DateTime? lastDate;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    itemCount: visibleDocs.length,
                    itemBuilder: (context, index) {
                      final doc = visibleDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final isMe = data['senderId'] == widget.currentUser.uid;
                      final isDeleted = data['deleted'] == true;
                      final text =
                          isDeleted ? '' : (decryptedById[doc.id] ?? '');

                      Widget? separator;
                      final ts = data['timestamp'] as Timestamp?;
                      if (ts != null && !_isSearching) {
                        final msgDate = ts.toDate();
                        final dayOnly =
                            DateTime(msgDate.year, msgDate.month, msgDate.day);
                        if (lastDate == null || dayOnly != lastDate) {
                          lastDate = dayOnly;
                          separator = _buildDateSeparator(msgDate);
                        }
                      }

                      final replyToId = data['replyToId'] as String?;
                      final replyPreview =
                          replyToId != null ? decryptedById[replyToId] : null;
                      final replySenderId = data['replyToSenderId'] as String?;

                      return Column(
                        children: [
                          if (separator != null) separator,
                          Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: GestureDetector(
                              onLongPress: isDeleted
                                  ? null
                                  : () => _showMessageActions(
                                        docId: doc.id,
                                        data: data,
                                        decrypted: text,
                                        isMe: isMe,
                                      ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.75),
                                decoration: BoxDecoration(
                                  color: isMe ? bubbleMe : bubbleOther,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(20),
                                    topRight: const Radius.circular(20),
                                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                                    bottomRight: Radius.circular(isMe ? 4 : 20),
                                  ),
                                  border: Border.all(
                                    color: isMe
                                        ? accentNeon.withOpacity(0.15)
                                        : Colors.black.withOpacity(0.02),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isDeleted && replyPreview != null)
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.03),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border(
                                            left: BorderSide(
                                                color:
                                                    accentNeon.withOpacity(0.6),
                                                width: 3),
                                          ),
                                        ),
                                        child: Text(
                                          replySenderId ==
                                                  widget.currentUser.uid
                                              ? 'You: $replyPreview'
                                              : replyPreview,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 12.5,
                                              color: textSecondary,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    Text(
                                      isDeleted
                                          ? 'This message was deleted'
                                          : _capitalizeFirst(text),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isDeleted
                                            ? textSecondary
                                            : textMain,
                                        fontStyle: isDeleted
                                            ? FontStyle.italic
                                            : FontStyle.normal,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (!isDeleted)
                                          GestureDetector(
                                            onTap: () => _showVerifySheet(data),
                                            child: const Icon(
                                              Icons.shield_outlined,
                                              size: 12,
                                              color: verifiedGreen,
                                            ),
                                          ),
                                        if (!isDeleted)
                                          const SizedBox(width: 4),
                                        Text(
                                          data['timestamp'] != null
                                              ? formatTimestamp(
                                                  data['timestamp'])
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (isMe && !isDeleted) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.done_all_rounded,
                                            size: 13,
                                            color: data['status'] == 'seen'
                                                ? accentNeon
                                                : textSecondary,
                                          ),
                                        ]
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            _buildReplyPreview(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: bubbleOther,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDateSeparator(date),
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingBanner() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final typingMap = data?['typing'] as Map<String, dynamic>?;
        final otherTyping = typingMap?[widget.otherUser['uid']] == true;

        if (!otherTyping) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: bubbleOther,
          child: Text(
            '${_capitalizeFirst(widget.otherUser['name'] ?? 'They')} is typing…',
            style: const TextStyle(
                fontSize: 12,
                color: textSecondary,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic),
          ),
        );
      },
    );
  }

  Widget _buildReplyPreview() {
    if (_replyingTo == null) return const SizedBox.shrink();
    final isMe = _replyingTo!['senderId'] == widget.currentUser.uid;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bubbleOther,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: accentNeon.withOpacity(0.7), width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe ? 'Replying to yourself' : 'Replying',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accentNeon),
                ),
                const SizedBox(height: 2),
                Text(
                  _replyingTo!['text'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.close_rounded, size: 18, color: textSecondary),
            onPressed: () => setState(() => _replyingTo = null),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildDefaultAppBar() {
    final photoUrl = widget.otherUser['photoUrl'] as String?;

    return AppBar(
      backgroundColor: surfaceWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 75,
      leadingWidth: 50,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: textMain, size: 20),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const Bottomnavscreen(),
              ),
            );
          },
        ),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                backgroundImage:
                    const AssetImage('assets/images/lightprofile.png')
                        as ImageProvider,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.otherUser['uid'])
                      .snapshots(),
                  builder: (context, snap) {
                    final isOnline = snap.hasData &&
                        snap.data!.exists &&
                        (snap.data!.data()
                                as Map<String, dynamic>?)?['isOnline'] ==
                            true;
                    if (!isOnline) return const SizedBox.shrink();
                    return Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: verifiedGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: surfaceWhite, width: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalizeFirst(
                      widget.otherUser['name'] ?? 'Identity Missing'),
                  style: const TextStyle(
                    fontSize: 17,
                    color: textMain,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.otherUser['uid'])
                      .snapshots(),
                  builder: (context, snap) {
                    final userData = snap.hasData && snap.data!.exists
                        ? snap.data!.data() as Map<String, dynamic>?
                        : null;
                    final isOnline = userData?['isOnline'] == true;

                    return Row(
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            size: 11,
                            color: isOnline ? verifiedGreen : accentNeon),
                        const SizedBox(width: 4),
                        Text(
                          isOnline ? 'Online · Encrypted' : 'Encrypted Matrix',
                          style: const TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: textMain),
          onPressed: () => setState(() => _isSearching = true),
        ),
      ],
      shape: Border(
        bottom: BorderSide(color: Colors.black.withOpacity(0.06), width: 0.8),
      ),
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: surfaceWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: textMain),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchQuery = '';
            _searchController.clear();
          });
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(fontSize: 15, color: textMain),
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Search this conversation…',
          hintStyle: TextStyle(color: textSecondary, fontSize: 14.5),
        ),
      ),
      shape: Border(
        bottom: BorderSide(color: Colors.black.withOpacity(0.06), width: 0.8),
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: bubbleOther,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(fontSize: 15, color: textMain),
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Type a secure message...",
                    hintStyle: TextStyle(
                        color: textSecondary.withOpacity(0.6), fontSize: 14.5),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: sendMessage,
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: accentNeon,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: accentNeon.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: surfaceWhite,
                  size: 20,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
