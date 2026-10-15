import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/dummy_data.dart';
import '../widgets/common.dart';
import 'venue_detail_screen.dart';

/// 찜한 파티 보기 (+ 찜한 베뉴).
class LikedScreen extends StatelessWidget {
  const LikedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final likedEvents = events.where((e) => state.likedEvents.contains(e.id)).toList();
    final likedVenues = venues.where((v) => state.likedVenues.contains(v.id)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('찜')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SectionTitle('찜한 파티'),
          if (likedEvents.isEmpty) const EmptyText('찜한 파티가 없어요. 공연 상세에서 하트를 눌러보세요.'),
          for (final e in likedEvents) EventListTile(event: e),
          const SectionTitle('찜한 베뉴'),
          if (likedVenues.isEmpty) const EmptyText('찜한 베뉴가 없어요.'),
          for (final v in likedVenues) VenueListTile(venue: v),
        ],
      ),
    );
  }
}
