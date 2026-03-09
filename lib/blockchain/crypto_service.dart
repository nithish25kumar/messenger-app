import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

class CryptoService {
  /// Generate AES key
  Key generateKey() {
    final key = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    return Key(Uint8List.fromList(key));
  }

  /// Encrypt message
  Map<String, dynamic> encryptMessage(String message, Key key) {
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(message, iv: iv);

    return {
      "cipherText": encrypted.base64,
      "iv": iv.base64,
      "key": key.base64,
    };
  }

  /// Hash message
  String hashMessage(String message) {
    final bytes = utf8.encode(message);
    return sha256.convert(bytes).toString();
  }
}
