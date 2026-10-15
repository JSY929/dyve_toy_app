import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models.dart';
import '../widgets/common.dart';

/// 홈: 추천 공연 배너, 예매 가능한 행사, DYVE PICK, 관객/주최자 안내.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final picks = events.where((e) => e.pick).toList();
    final onSale = events.where((e) => e.onSale).toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SizedBox(
          height: 440,
          child: PageView(children: [for (final e in picks) _Banner(event: e)]),
        ),
        const SectionTitle('DYVE에서 예매 가능한 행사'),
        SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: onSale.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, i) => SizedBox(width: 190, child: EventCard(event: onSale[i])),
          ),
        ),
        const SectionTitle('DYVE PICK', subtitle: 'DYVE 에디터가 직접 고른, 이번 주에 꼭 가야만 하는 행사'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          mainAxisSpacing: 20,
          crossAxisSpacing: 14,
          childAspectRatio: 0.62,
          children: [for (final e in picks) EventCard(event: e)],
        ),
        const SizedBox(height: 16),
        const _GuideCard(
          label: '관객',
          title: '즐거움을 찾는\n여러분들을 위해',
          body: '관객이 예매 절차보다\n행사 경험에 집중할 수 있도록.',
          action: '관객 가이드 보기',
          steps: ['티켓·홈 탭에서 행사를 찾아요.', '공연 상세에서 예매하기를 눌러 회차·수량·결제 수단을 고르세요.', '마이 탭 내 티켓에서 QR을 입장 시 보여주세요.'],
        ),
        const _GuideCard(
          label: '주최자',
          title: '행사를 여는\n여러분들을 위해',
          body: '티켓 판매부터 입장 관리까지\nDYVE 하나로.',
          action: '주최자 가이드 보기',
          steps: ['토이 앱은 관객용 화면만 제공합니다.', '주최자 기능은 실제 DYVE 서비스에서 확인하세요.'],
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final venue = venueById(event.venueId);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Poster(event: event, showTitle: false, radius: 20),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 8),
                if (event.sessions.length > 1) const Pill('다회차 공연'),
                const SizedBox(height: 8),
                Text(fmtSessions(event.sessions), style: const TextStyle(color: Colors.white)),
                Text(venue.name, style: const TextStyle(color: Colors.white)),
                Text(
                  '${won(event.price)} · ${event.onSale ? '판매 중' : '판매 예정'}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                FilledButton(onPressed: () => openEvent(context, event), child: const Text('공연 보기')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.label,
    required this.title,
    required this.body,
    required this.action,
    required this.steps,
  });

  final String label;
  final String title;
  final String body;
  final String action;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: kMuted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(body, style: const TextStyle(color: Colors.white70)),
          TextButton.icon(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(action),
                content: Text([for (var i = 0; i < steps.length; i++) '${i + 1}. ${steps[i]}'].join('\n')),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인'))],
              ),
            ),
            icon: const Icon(Icons.arrow_forward),
            label: Text(action),
          ),
        ],
      ),
    );
  }
}
