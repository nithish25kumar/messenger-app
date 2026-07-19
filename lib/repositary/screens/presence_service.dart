import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

/// Manages the current user's online/offline presence using Firebase
/// Realtime Database's `onDisconnect()` hook. This is the standard
/// pattern recommended by Firebase because RTDB fires the disconnect
/// write server-side even if the app is killed, loses network, or
/// crashes — a Firestore-only "heartbeat" approach can't guarantee that.
///
/// A Cloud Function (see cloud_functions/index.js) mirrors the RTDB
/// status into `users/{uid}` in Firestore, so the rest of the app
/// (chat list, chat screen) can keep reading presence from Firestore
/// like everything else, without needing two databases in the UI layer.
///
/// Usage:
///   PresenceService.instance.start(currentUser.uid); // after login
///   PresenceService.instance.stop();                 // on sign out
class PresenceService with WidgetsBindingObserver {
  PresenceService._internal();
  static final PresenceService instance = PresenceService._internal();

  final _rtdb = FirebaseDatabase.instance;
  StreamSubscription<DatabaseEvent>? _connectionSub;
  String? _uid;

  void start(String uid) {
    // Safe to call from more than one screen (e.g. once at login and
    // again defensively from ChatScreen) — we only attach once per uid.
    if (_uid == uid && _connectionSub != null) return;
    _uid = uid;
    WidgetsBinding.instance.addObserver(this);

    final myStatusRef = _rtdb.ref('status/$uid');
    final connectedRef = _rtdb.ref('.info/connected');

    _connectionSub = connectedRef.onValue.listen((event) async {
      final connected = event.snapshot.value == true;
      if (!connected) return;

      // Queue the "went offline" write server-side, to fire the moment
      // this client disconnects for any reason.
      await myStatusRef.onDisconnect().set({
        'state': 'offline',
        'last_changed': ServerValue.timestamp,
      });

      // We're online right now.
      await myStatusRef.set({
        'state': 'online',
        'last_changed': ServerValue.timestamp,
      });
    });
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
    _connectionSub?.cancel();
    final uid = _uid;
    if (uid != null) {
      _rtdb.ref('status/$uid').set({
        'state': 'offline',
        'last_changed': ServerValue.timestamp,
      });
    }
    _uid = null;
  }

  // Backgrounding the app counts as "away" even before the socket
  // actually drops, which makes presence feel snappier.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final uid = _uid;
    if (uid == null) return;
    final ref = _rtdb.ref('status/$uid');
    if (state == AppLifecycleState.resumed) {
      ref.set({'state': 'online', 'last_changed': ServerValue.timestamp});
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      ref.set({'state': 'offline', 'last_changed': ServerValue.timestamp});
    }
  }

  /// Live presence for another user, read from Firestore (kept in sync
  /// by the Cloud Function).
  Stream<UserPresence> watchUser(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => UserPresence(
              isOnline: doc.data()?['isOnline'] ?? false,
              lastSeen: doc.data()?['lastSeen'] as Timestamp?,
            ));
  }
}

class UserPresence {
  final bool isOnline;
  final Timestamp? lastSeen;
  const UserPresence({required this.isOnline, this.lastSeen});

  String label() {
    if (isOnline) return 'Online';
    final ts = lastSeen;
    if (ts == null) return 'Offline';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'Last seen just now';
    if (diff.inMinutes < 60) return 'Last seen ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Last seen ${diff.inHours}h ago';
    return 'Last seen ${diff.inDays}d ago';
  }
}
