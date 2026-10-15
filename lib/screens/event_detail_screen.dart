import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/dummy_data.dart';
import '../models.dart';
import '../widgets/common.dart';
import 'checkout_screen.dart';
import 'venue_detail_screen.dart';

/// 공연 상세: 라인업, 소개, 안내, 환불 규정 + 참석자 보기 + 예매하기.
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.event});

  final Event event;

  Future<void> _book(BuildContext context) async {
    if (!await ensureLoggedIn(context) || !context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CheckoutScreen(event: event)));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final venue = venueById(event.venueId);
    final liked = state.likedEvents.contains(event.id);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: '찜',
            icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? kCoral : null),
            onPressed: () async {
              if (await ensureLoggedIn(context) && context.mounted) AppScope.read(context).toggleEventLike(event.id);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SizedBox(height: 340, child: Poster(event: event, fontSize: 32, radius: 0)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: [if (event.pick) const Pill('DYVE PICK', highlighted: true), Pill(event.category)],
                ),
                const SizedBox(height: 12),
                Text(event.title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Text(fmtSessions(event.sessions), style: const TextStyle(fontWeight: FontWeight.w700)),
                InkWell(
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute<void>(builder: (_) => VenueDetailScreen(venue: venue))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('${venue.name} · ${venue.region}  ›', style: const TextStyle(color: Colors.white70)),
                  ),
                ),
                Text(
                  '${won(event.price)} · ${event.onSale ? '판매 중' : '판매 예정'}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          _Section(
            "WHO'S GOING",
            state.loggedIn
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final name in event.attendees)
                            Chip(
                              avatar: CircleAvatar(child: Text(name.characters.first)),
                              label: Text(name),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('${event.attendees.length}명이 참석 예정이에요.', style: const TextStyle(color: kMuted)),
                    ],
                  )
                : TextButton(onPressed: () => ensureLoggedIn(context), child: const Text('로그인하고 참석자 보기')),
          ),
          _Section(
            'LINEUP',
            Text(
              event.lineup.join('  ·  '),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.6),
            ),
          ),
          _Section('ABOUT', Text(event.about, style: const TextStyle(height: 1.6))),
          _Section('입장 안내', Text(event.entryInfo, style: const TextStyle(height: 1.6))),
          const _Section('취소·환불', _RefundTable()),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: kLine)),
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('티켓', style: TextStyle(color: kMuted, fontSize: 12)),
                  Text(won(event.price), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  onPressed: event.onSale ? () => _book(context) : null,
                  child: Text(event.onSale ? '예매하기' : '판매 예정'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.child);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RefundTable extends StatelessWidget {
  const _RefundTable();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('공연별 취소·환불 규정', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text(refundNote, style: TextStyle(color: kMuted)),
        const SizedBox(height: 8),
        for (final (period, rule) in refundRules)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: kLine)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(period, style: const TextStyle(color: kMuted)),
                ),
                Text(rule, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
      ],
    );
  }
}
