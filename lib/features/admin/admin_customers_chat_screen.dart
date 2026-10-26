import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/lm_glass_widgets.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

class AdminCustomersChatScreen extends StatefulWidget {
  const AdminCustomersChatScreen({super.key});

  @override
  State<AdminCustomersChatScreen> createState() =>
      _AdminCustomersChatScreenState();
}

class _AdminCustomersChatScreenState extends State<AdminCustomersChatScreen> {
  final TextEditingController _replyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChatProvider>().loadMessages();
      }
    });
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendAdminReply(BuildContext context) async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty) return;
    _replyCtrl.clear();
    await context.read<ChatProvider>().sendMessage(
      text,
      senderName: 'Quản trị viên SmartStore (Admin)',
      isAdmin: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AuthProvider>().palette;
    final messages = context.watch<ChatProvider>().messages;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Khách hàng & CSKH (A07, A09)'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Danh sách Khách hàng (A07)'),
              Tab(text: 'Phản hồi Chat CSKH (A09)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Danh sách khách hàng (A07)
            FutureBuilder<List<UserModel>>(
              future: context.read<AuthProvider>().getAllCustomers(),
              builder: (context, snapshot) {
                final users = snapshot.data ?? [];
                if (snapshot.connectionState == ConnectionState.waiting &&
                    users.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final u = users[index];
                    return LmMaterialCard(
                      padding: const EdgeInsets.all(14),
                      borderRadius: 16,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: palette.primarySoft,
                            child: Text(
                              u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
                              style: TextStyle(
                                color: palette.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  u.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${u.email} • ${u.phone}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.ink3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          LmStatusPill(
                            text: u.isAdmin ? 'ADMIN' : 'CUSTOMER',
                            color: u.isAdmin
                                ? palette.primary
                                : AppColors.success,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            // Tab 2: Phản hồi Chat CSKH (A09)
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMeAdmin = msg.isAdmin;
                      return Align(
                        alignment: isMeAdmin
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          constraints: const BoxConstraints(maxWidth: 300),
                          decoration: BoxDecoration(
                            color: isMeAdmin
                                ? palette.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: isMeAdmin
                                ? null
                                : Border.all(color: AppColors.line),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.senderName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isMeAdmin
                                      ? Colors.white70
                                      : AppColors.ink3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                msg.text,
                                style: TextStyle(
                                  color: isMeAdmin
                                      ? Colors.white
                                      : AppColors.ink,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.line)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _replyCtrl,
                          onSubmitted: (_) => _sendAdminReply(context),
                          decoration: const InputDecoration(
                            hintText:
                                'Nhập phản hồi của Admin cho khách hàng...',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        onPressed: () => _sendAdminReply(context),
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
