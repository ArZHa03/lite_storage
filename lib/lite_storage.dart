import 'dart:async';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/widgets.dart';

import 'i_lite_storage.dart';
import 'io_storage.dart';

class LiteStorage implements ILiteStorage {
  static final Map<String, LiteStorage> _sync = {};
  late Future<LiteStorage> _initStorage;
  late Storage _concrete;
  Map<String, dynamic>? _initialData;
  final String _kNonce = 'nonce';
  final String _kMac = 'mac';
  final String _kCipherText = 'cipherText';
  AesCtr? _algorithm;
  SecretKey? _secretKey;

  factory LiteStorage({String container = 'LiteStorage', String? password, String? path, Map<String, dynamic>? initialData}) {
    if (_sync.containsKey(container)) {
      return _sync[container]!;
    } else {
      final instance = LiteStorage._internal(container, path, initialData, password);
      _sync[container] = instance;
      return instance;
    }
  }

  LiteStorage._internal(String key, [String? path, Map<String, dynamic>? initialData, String? password]) {
    _concrete = Storage(key);
    _initialData = initialData;

    _initStorage = Future<LiteStorage>(() async {
      if (password != null) {
        _algorithm = AesCtr.with128bits(macAlgorithm: Hmac.sha256());
        final pbkdf2 = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 1000, bits: 128);
        _secretKey = await pbkdf2.deriveKeyFromPassword(password: password, nonce: password.runes.toList().reversed.toList());
      }
      await _init();
      return this;
    });
  }

  Future<void> _init() async {
    try {
      await _concrete.init(_initialData, _encrypt, _decrypt);
    } catch (err) {
      rethrow;
    }
  }

  Future<LiteStorage> init({String container = 'LiteStorage', String? password}) {
    WidgetsFlutterBinding.ensureInitialized();
    return LiteStorage(container: container, password: password)._initStorage;
  }

  @override
  T? read<T>(String key) => _concrete.read(key);
  @override
  void write(String key, dynamic value) => _concrete.write(key, value);
  @override
  void remove(String key) => _concrete.remove(key);
  @override
  void erase() => _concrete.clear();

  String _listToHexString(List<int> bytes) => bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

  List<int> _hexStringToList(String hexString) {
    List<int> data = [];
    for (int i = 0; i < hexString.length; i += 2) {
      int byte = int.parse(hexString.substring(i, i + 2), radix: 16);
      data.add(byte);
    }
    return data;
  }

  Future<String> _encrypt(String value) async {
    if (_algorithm != null) {
      final secretBox = await _algorithm!.encryptString(value, secretKey: _secretKey!);
      final jsonPayload = {
        _kNonce: _listToHexString(secretBox.nonce),
        _kMac: _listToHexString(secretBox.mac.bytes),
        _kCipherText: _listToHexString(secretBox.cipherText),
      };
      return json.encode(jsonPayload);
    }

    final dynamic jsonPayload = json.decode(value) ?? {};
    if (jsonPayload.containsKey(_kCipherText) || jsonPayload.containsKey(_kMac) || jsonPayload.containsKey(_kNonce)) {
      jsonPayload.remove(_kCipherText);
      jsonPayload.remove(_kMac);
      jsonPayload.remove(_kNonce);
      return json.encode(jsonPayload);
    }
    return value;
  }

  Future<String> _decrypt(String value) async {
    if (_algorithm != null) {
      final jsonPayload = json.decode(value);

      if (jsonPayload == null || !jsonPayload.containsKey(_kCipherText) || !jsonPayload.containsKey(_kMac) || !jsonPayload.containsKey(_kNonce)) {
        return value;
      }

      if (jsonPayload[_kNonce] is! String || jsonPayload[_kCipherText] is! String || jsonPayload[_kMac] is! String) return '';

      final secretBox = SecretBox(_hexStringToList(jsonPayload[_kCipherText]),
          nonce: _hexStringToList(jsonPayload[_kNonce]), mac: Mac(_hexStringToList(jsonPayload[_kMac])));

      try {
        return await _algorithm!.decryptString(secretBox, secretKey: _secretKey!);
      } catch (e) {
        rethrow;
      }
    }
    return value;
  }
}
