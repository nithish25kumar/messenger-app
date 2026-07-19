/**
 * Mirrors /status/{uid} in Realtime Database into Firestore's
 * users/{uid} document, so the rest of the app can keep reading
 * presence from Firestore (where everything else already lives)
 * while still getting RTDB's reliable onDisconnect() semantics.
 *
 * Deploy with:
 *   firebase deploy --only functions:syncPresenceToFirestore
 *
 * Requires firebase-functions v5+ (2nd gen, database triggers).
 */
const { onValueWritten } = require('firebase-functions/v2/database');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp();
const db = getFirestore();

exports.syncPresenceToFirestore = onValueWritten(
  '/status/{uid}',
  async (event) => {
    const uid = event.params.uid;
    const status = event.data.after.val();

    if (!status) return null;

    return db.collection('users').doc(uid).set(
      {
        isOnline: status.state === 'online',
        lastSeen: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  }
);
