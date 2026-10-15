import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/common.dart';
import 'liked_screen.dart';
import 'login_screen.dart';
import 'ticket_qr_screen.dart';

void _push(BuildContext context, Widget screen) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

/// 마이 탭: 비로그인 시 로그인 안내, 로그인 시 내 티켓·QR·고객센터.
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (!state.loggedIn) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Icon(Icons.account_circle_outlined, color: kCoral, size: 64),
            const SizedBox(height: 12),
            const Text('MY', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('파티를 발견하고, 친구들과 함께 즐겨보세요.', style: TextStyle(color: kMuted)),
            const SizedBox(height: 28),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              onPressed: () => _push(context, const LoginScreen()),
              child: const Text('로그인'),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: () => _push(context, const SupportScreen()), child: const Text('고객센터')),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          leading: const CircleAvatar(
            backgroundColor: kCoral,
            child: Icon(Icons.person, color: Colors.black),
          ),
          title: const Text('관객님', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          subtitle: Text('${state.loginProvider} 계정으로 로그인됨 (모의)'),
        ),
        const SectionTitle('내 티켓'),
        if (state.tickets.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text('아직 예매한 티켓이 없어요.', style: TextStyle(color: kMuted)),
                ),
                TextButton(onPressed: () => state.setTab(1), child: const Text('이벤트 둘러보기')),
              ],
            ),
          ),
        for (final t in state.tickets)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: kSurface,
            child: ListTile(
              leading: SizedBox(width: 44, height: 56, child: Poster(event: t.event, fontSize: 8, radius: 6)),
              title: Text(t.event.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${fmtDateTime(t.session)} · ${t.quantity}매'),
              trailing: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_2, color: kCoral),
                  Text('QR 보기', style: TextStyle(fontSize: 11)),
                ],
              ),
              onTap: () => _push(context, TicketQrScreen(ticket: t)),
            ),
          ),
        const Divider(height: 40),
        ListTile(
          leading: const Icon(Icons.favorite_border),
          title: const Text('찜 목록'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _push(context, const LikedScreen()),
        ),
        ListTile(
          leading: const Icon(Icons.support_agent),
          title: const Text('고객센터'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _push(context, const SupportScreen()),
        ),
        ListTile(leading: const Icon(Icons.logout), title: const Text('로그아웃'), onTap: state.logout),
      ],
    );
  }
}

/// 고객센터 보기 (더미 FAQ).
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const _faq = [
    ('예매한 티켓은 어디서 보나요?', '마이 탭 > 내 티켓에서 확인하고, 입장 시 QR을 보여주세요.'),
    ('예매를 취소하고 싶어요.', '공연 72시간 전까지 전액 환불됩니다. 토이 앱에서는 취소 기능을 제공하지 않아요.'),
    ('결제 수단은 무엇이 있나요?', '카드, 간편결제, PayPal을 선택할 수 있어요. 토이 앱은 모의 결제만 지원합니다.'),
    ('로그인은 어떻게 하나요?', '카카오 또는 네이버로 계속하기를 누르면 됩니다. 토이 앱은 실제 인증을 하지 않아요.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('고객센터')),
      body: ListView(
        children: [
          const SectionTitle('자주 묻는 질문'),
          for (final (q, a) in _faq)
            ExpansionTile(
              title: Text(q),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedAlignment: Alignment.centerLeft,
              children: [Text(a, style: const TextStyle(color: Colors.white70))],
            ),
          const SectionTitle('문의하기'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '운영 시간: 평일 10:00 ~ 18:00\n이메일: help@example.com (토이 앱 더미 정보)',
              style: TextStyle(color: kMuted, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
