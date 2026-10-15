import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../widgets/common.dart';

/// 티켓 탭: 다가오는 이벤트 + 기간 필터.
class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  static const _filters = ['오늘 밤', '이번 주', '전체'];
  int _filter = 2;

  bool _inPeriod(DateTime d) => switch (_filter) {
    0 => isToday(d),
    1 => withinDays(d, 7),
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    final list = events.where((e) => e.sessions.any(_inPeriod)).toList()
      ..sort((a, b) => a.sessions.first.compareTo(b.sessions.first));
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SectionTitle(
          '지금, 참여할 이벤트를 찾아보세요',
          eyebrow: 'EVENTS ON DYVE',
          subtitle: '예매는 간단하게, 입장은 빠르게.\n공연부터 파티, 네트워킹까지 DYVE에서 이어집니다.',
        ),
        const Divider(),
        const SectionTitle('다가오는 이벤트', eyebrow: 'UPCOMING'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (var i = 0; i < _filters.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: i == _filter
                        ? FilledButton(onPressed: () {}, child: Text(_filters[i]))
                        : OutlinedButton(onPressed: () => setState(() => _filter = i), child: Text(_filters[i])),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (list.isEmpty) const EmptyText('해당 기간에 예정된 이벤트가 없어요.'),
        for (final e in list) EventListTile(event: e),
      ],
    );
  }
}
