import 'package:flutter/foundation.dart';

import '../data/repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository;

  ChatProvider({ChatRepository? chatRepository})
    : _chatRepository = chatRepository ?? ChatRepository() {
    loadMessages();
  }

  List<ChatMessageModel> get messages => _chatRepository.messages;

  Future<void> loadMessages({String chatId = 'default_support_chat'}) async {
    await _chatRepository.loadMessages(chatId: chatId);
    notifyListeners();
  }

  Future<void> sendMessage(
    String text, {
    String senderName = 'Khách hàng',
    bool isAdmin = false,
    String chatId = 'default_support_chat',
  }) async {
    if (text.trim().isEmpty) return;
    await _chatRepository.sendMessage(
      chatId: chatId,
      senderName: senderName,
      isAdmin: isAdmin,
      text: text.trim(),
    );
    notifyListeners();
  }
}
