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
}

class ChatRepository {
  final List<ChatMessageModel> _messages = [
    ChatMessageModel(
      id: 'msg_welcome_1',
      senderName: 'SmartStore Support',
      isAdmin: true,
      text: 'Xin chào! SmartStore có thể tư vấn mẫu iPhone 16, Galaxy S25 hay kiểm tra đơn hàng nào giúp bạn?',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  bool get _isFirebaseReady =>
      Firebase.apps.isNotEmpty && !ConnectivityService.offlineSimulationEnabled;

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);

  Future<void> sendMessage({
    required String chatId,
    required String senderName,
    required bool isAdmin,
    required String text,
  }) async {
    final msg = ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderName: senderName,
      isAdmin: isAdmin,
      text: text,
      createdAt: DateTime.now(),
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
              'createdAt': FieldValue.serverTimestamp(),
            });
      } catch (_) {}
    }
  }
}
