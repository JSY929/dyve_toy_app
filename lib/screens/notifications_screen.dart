import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/common.dart';

/// 알림 확인 (로그인 후에만 진입).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = state.notifications;
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        actions: [TextButton(onPressed: state.markAllRead, child: const Text('모두 읽음'))],
      ),
      body: items.isEmpty
          ? const Center(
              child: Text('새 알림이 없어요.', style: TextStyle(color: kMuted)),
            )
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final n = items[i];
                return ListTile(
                  leading: Icon(
                    n.read ? Icons.notifications_none : Icons.notifications_active,
                    color: n.read ? kMuted : kCoral,
                  ),
                  title: Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.normal : FontWeight.w700)),
                  subtitle: Text('${n.body}\n${fmtDateTime(n.time)}'),
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}
