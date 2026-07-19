import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/constants/appcolors.dart';
import 'chats/chatscreen.dart';

class ChatListScreen extends StatefulWidget {
  final User currentUser;
  const ChatListScreen({super.key, required this.currentUser});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  static const Color _accentStart = Color(0xFF6C5CE7);
  static const Color _accentEnd = Color(0xFF00B4D8);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '$uid1\_$uid2' : '$uid2\_$uid1';
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  String _formatTimestamp(dynamic ts) {
    if (ts == null || ts is! Timestamp) return '';
    final date = ts.toDate();
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday) {
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }
    return '${date.month}/${date.day}/${date.year % 100}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            const SizedBox(height: 4),
            _buildSearchField(theme),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(_accentStart),
                      ),
                    );
                  }

                  var users = snapshot.data!.docs
                      .where((doc) => doc['uid'] != widget.currentUser.uid)
                      .toList();

                  if (_query.trim().isNotEmpty) {
                    final q = _query.trim().toLowerCase();
                    users = users.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name =
                          (data['name'] as String?)?.toLowerCase() ?? '';
                      return name.contains(q);
                    }).toList();
                  }

                  if (users.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final doc = users[index];
                      final userData = doc.data() as Map<String, dynamic>;
                      return _buildChatCard(theme, userData);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messages',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    color: Colors.black),
              ),
              const SizedBox(height: 2),
              Text(
                'Stay in the loop',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_accentStart, _accentEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.mark_chat_read_rounded,
                color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
            hintText: 'Search conversations',
            hintStyle: TextStyle(
                color: theme.hintColor.withOpacity(0.7), fontSize: 14.5),
            prefixIcon:
                Icon(Icons.search_rounded, color: theme.hintColor, size: 20),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildChatCard(ThemeData theme, Map<String, dynamic> userData) {
    // Helper to capitalize only the first letter of a string
    String capitalizeFirst(String? text) {
      if (text == null || text.trim().isEmpty) return '';
      final trimmed = text.trim();
      return trimmed[0].toUpperCase() + trimmed.substring(1);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                currentUser: widget.currentUser,
                otherUser: userData,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(userData),
              const SizedBox(width: 14),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(getChatId(widget.currentUser.uid, userData['uid']))
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .limit(1)
                      .snapshots(),
                  builder: (context, msgSnap) {
                    final hasMsg =
                        msgSnap.hasData && msgSnap.data!.docs.isNotEmpty;
                    Map<String, dynamic>? lastMessage;
                    if (hasMsg) {
                      lastMessage = msgSnap.data!.docs.first.data()
                          as Map<String, dynamic>;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                capitalizeFirst(userData['name'] ??
                                    'No name'), // Caps first letter
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (hasMsg)
                              Text(
                                _formatTimestamp(lastMessage?['timestamp']),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: theme.hintColor,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasMsg
                              ? capitalizeFirst(
                                  lastMessage?['message']) // Caps first letter
                              : 'Say hello 👋',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: hasMsg
                                ? theme.hintColor
                                : _accentStart.withOpacity(0.8),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: theme.hintColor.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> userData) {
    final photoUrl = userData['photoUrl'] as String?;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [_accentStart, _accentEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white,
        backgroundImage: AssetImage('assets/images/lightprofile.png'),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accentStart.withOpacity(0.12),
                    _accentEnd.withOpacity(0.12),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.forum_rounded,
                size: 46,
                color: _accentStart,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _query.isNotEmpty ? 'No matches found' : 'No conversations yet',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _query.isNotEmpty
                  ? 'Try a different name'
                  : 'Once people join, they will show up here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: theme.hintColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
