import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/services/connectivity_service.dart';
import '../../core/constants/firestore_collections.dart';

class ChatMessageModel {
  final String id;
  final String senderName;
  final bool isAdmin;
  final String text;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.senderName,
    required this.isAdmin,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(String id, Map<String, dynamic> json) {
    DateTime created = DateTime.now();
    final rawCreated = json['createdAt'];
    if (rawCreated is Timestamp) {
      created = rawCreated.toDate();
    } else if (rawCreated is String) {
      created = DateTime.tryParse(rawCreated) ?? DateTime.now();
    }
    return ChatMessageModel(
      id: id,
      senderName: json['senderName']?.toString() ?? 'Khách hàng',
      isAdmin: json['isAdmin'] as bool? ?? false,
      text: json['text']?.toString() ?? '',
      createdAt: created,
    );
  }
}

class ChatRepository {
  final List<ChatMessageModel> _messages = [
    ChatMessageModel(
      id: 'msg_welcome_1',
      senderName: 'SmartStore Support',
      isAdmin: true,
      text:
          'Xin chào! SmartStore có thể tư vấn mẫu iPhone 16, Galaxy S25 hay kiểm tra đơn hàng nào giúp bạn?',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  bool get _isFirebaseReady =>
      Firebase.apps.isNotEmpty && !ConnectivityService.offlineSimulationEnabled;

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);

  Future<void> loadMessages({String chatId = 'default_support_chat'}) async {
    if (!_isFirebaseReady) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection(FirestoreCollections.chats)
          .doc(chatId)
          .collection(FirestoreCollections.messages)
          .orderBy('createdAt')
          .get();
      if (snap.docs.isNotEmpty) {
        final cloudMsgs = snap.docs
            .map((d) => ChatMessageModel.fromJson(d.id, d.data()))
            .toList();
        for (final m in cloudMsgs) {
          final idx = _messages.indexWhere((existing) => existing.id == m.id);
          if (idx < 0) {
            _messages.add(m);
          } else {
            _messages[idx] = m;
          }
        }
        _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }
    } catch (_) {}
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderName,
    required bool isAdmin,
    required String text,
  }) async {
    final now = DateTime.now();
    final msg = ChatMessageModel(
      id: 'msg_${now.millisecondsSinceEpoch}',
      senderName: senderName,
      isAdmin: isAdmin,
      text: text,
      createdAt: now,
    );
    _messages.add(msg);

    if (_isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection(FirestoreCollections.chats)
            .doc(chatId)
            .collection(FirestoreCollections.messages)
            .doc(msg.id)
            .set({
              'senderName': senderName,
              'isAdmin': isAdmin,
              'text': text,
              'createdAt': now.toUtc().toIso8601String(),
            });
      } catch (_) {}
    }
  }
}
