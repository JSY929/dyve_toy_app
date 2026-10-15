import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/dummy_data.dart';
import '../models.dart';
import '../widgets/common.dart';

void openVenue(BuildContext context, Venue venue) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => VenueDetailScreen(venue: venue)));
}

/// 베뉴 목록 행 (베뉴 탭 목록, 검색, 찜).
class VenueListTile extends StatelessWidget {
  const VenueListTile({super.key, required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(venue.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      subtitle: Text('${venue.area} · ${venue.type} · ${venue.genre}\n${venue.address}'),
      isThreeLine: true,
      trailing: const Icon(Icons.north_east),
      onTap: () => openVenue(context, venue),
    );
  }
}

/// 베뉴 상세 + 베뉴 찜하기.
class VenueDetailScreen extends StatelessWidget {
  const VenueDetailScreen({super.key, required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final liked = state.likedVenues.contains(venue.id);
    final venueEvents = eventsAtVenue(venue.id);
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venue.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, color: kCoral, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('${venue.address} · ${venue.area}', style: const TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: [Pill(venue.type, highlighted: true), Pill(venue.genre)]),
                const Divider(height: 40),
                const Text('이곳의 행사', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                if (venueEvents.isEmpty) ...[
                  const Text('등록된 예정 행사가 없어요.', style: TextStyle(color: kMuted)),
                  const SizedBox(height: 4),
                  const Text('최신 일정과 운영 안내는 공식 링크에서 확인해 주세요.', style: TextStyle(color: kMuted, fontSize: 12)),
                ],
              ],
            ),
          ),
          for (final e in venueEvents) EventListTile(event: e),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton.outlined(
                tooltip: '베뉴 찜하기',
                style: IconButton.styleFrom(minimumSize: const Size(52, 52)),
                onPressed: () async {
                  if (await ensureLoggedIn(context) && context.mounted) {
                    AppScope.read(context).toggleVenueLike(venue.id);
                  }
                },
                icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? kCoral : null),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  onPressed: () {
                    final s = AppScope.read(context);
                    s.setVenueView(map: true, selected: venue.id);
                    s.setTab(2);
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  icon: const Icon(Icons.place_outlined),
                  label: const Text('지도에서 보기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
